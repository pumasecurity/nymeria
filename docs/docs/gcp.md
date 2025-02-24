# Google Cloud Workload Identity Federation

During the [Getting Started](./getting_started.md) section, you deployed the *03_gcp_init* Terraform configuration to your Google Cloud project. The Google configuration includes an Workload Identity Provider resource that trusts your Azure Entra ID tenant and a service account with permissions to read data from the Nymeria GCS bucket. In this section, we will explore how the Workload Identity Provider configuration trusts the Nymeria virtual machine and confirm the virtual machine can impersonate the Google Cloud service account.

## Google Cloud Workload Identity Provider

Inspect the Google Cloud Workload Identity Provider and Service Account configuration. Confirm the OpenID Connect token's subject, issuer, and audience claims match the values found in the Nymeria Virtual Machine Identity Token.

1. Sign into the [Google Cloud Web Console](https://console.cloud.google.com/){: target="_blank" rel="noopener"} again.

1. Navigate to the [IAM](https://console.cloud.google.com/iam-admin/iam){: target="_blank" rel="noopener"} service.

1. Select the *Workload Identity Federation* menu item from the left-hand menu. Then, open the *Azure Cross Cloud IdP* identity pool to view the details.

    ![](./img/gcp-workload-identity-federation.png)

1. In the right window, Select the *Azure VM* identity provider to view the details.

    ![](./img/gcp-workload-identity-pool.png)

1. Confirm the following configuration matches the Nymeria virtual machine's identity token. The configuration grants any identity token issued by the Azure Entra ID tenant to authenticate to the workload identity pool.

    - The **Issuer (URL)** matches the Nymeria virtual machine's identity token's `iss` claim: `https://sts.windows.net/[YOUR_AZURE_TENANT_ID]/`.

    - The **Allowed Audiences** includes one entry matching the Nymeria virtual machine's identity token's `aud` claim: `api://nymeria-workshop`.

    ![](./img/gcp-azure-pool.png)

1. The Workload Identity Pool and Provider resources do not inherently grant access to impersonate a service account. Permissions are granted by connecting a service account to the identity pool. Press the back button to navigate back to the workload identity pool. Then, select the *Connected Service Accounts* tab in the right window. Expand the *nymeria-cross-cloud-sa* service account to view the identity pool principals with access to impersonate the service account.

    ![](./img/gcp-azure-sa.png)

1. Confirm the `google.subject` filter restricts *nymeria-cross-cloud-sa* service account impersonation to the Nymeria virtual machine's managed identity.

!!! danger "Privilege Escalation Path"
    Misconfigured service account impersonation filters can allow privilege escalation vulnerabilities. Failing to apply a filter for a `principal` or `principalSet` can grant the entire workload identity pool service account impersonation.

## Google Cloud Workload Identity

Use the Nymeria virtual machine's OpenID Connect token to impersonate the Google Cloud service account. Then, use the temporary credentials to access data in Google Cloud Storage (GCS).

1. Browse to the [Azure Portal](https://portal.azure.com/){: target="_blank" rel="noopener"} open **Cloud Shell** again.

    ![](./img/az-portal.png)

1. Run the following command to connect to the Nymeria virtual machine over SSH.

    ```bash
    cd ~/clouddrive/nymeria/src/virtual_machines/04_gh_action/
    NYMERIA_FQDN=$(terraform output --json | jq -r '.azure_virtual_machine_fqdn.value')
    ssh -i ~/.ssh/nymeria.pem ubuntu@$NYMERIA_FQDN
    ```

    !!! abstract "Terminal Output"
        If you have successfully connected to the Nymeria virtual machine. The prompt should look like the following:

        ```bash
        Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.2.0-1012-azure x86_64)
        ...
        ubuntu@nymeria:~$
        ```

1. Source the environment variables in the `~/.config/gcloud/get-resources.sh` script and verify the project and bucket names are populated in the `GCS_BUCKET_ID` and `GCP_PROJECT_ID` environment variables.

    ```bash
    source ~/.config/gcloud/get-resources.sh
    echo $GCS_BUCKET_ID
    echo $GCP_PROJECT_ID
    ```

    !!! abstract "Terminal Output"
        ```bash
        nymeria-cross-cloud-abc123
        [YOUR_GOOGLE_PROJECT_ID]
        ```

1. Inspect the Google Cloud Workload Identity Federation client configuration file. Observe the following configuration values:

    - The `token_url` instructs the `gcloud` command line interface to obtain an authentication token from the Google Cloud STS API.

    - The `audience` attribute instructs the `gcloud` command line interface to authenticate to the Nymeria workload identity pool's `azure-vm` provider.

    - The `credential_source` attribute instructs the `gcloud` command line interface to obtain an OpenID Connect token from the Nymeria virtual machine's metadata service with the audience set to `api://nymeria-workshop`.

    - The `service_account_impersonation_url` attribute instructs the `gcloud` command line interface to use the workload identity pool's authentication token to impersonate the `nymeria-cross-cloud-sa` service account.

    ```bash
    cat ~/.config/gcloud/cross-cloud-client-config.json
    ```

    !!! abstract "Terminal Output"
        ```json
        {
            "type": "external_account",
            "audience": "//iam.googleapis.com/projects/123456789012/locations/global/workloadIdentityPools/nymeria-identity-pool-e9zwi7h7/providers/azure-vm-e9zwi7h7",
            "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
            "token_url": "https://sts.googleapis.com/v1/token",
            "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/nymeria-cross-cloud-sa@[YOUR_GOOGLE_PROJECT_ID].iam.gserviceaccount.com:generateAccessToken",
            "credential_source": {
                "url": "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=api://nymeria-workshop",
                "headers": {
                  "Metadata": "True"
                },
                "format": {
                  "type": "json",
                  "subject_token_field_name": "access_token"
                }
            }
        }
        ```

1. Run the following command to authenticate to the Google Cloud Workload Identity Pool using the client configuration file. Enter `Y` to overwrite the existing credential configuration.

    ```bash
    gcloud auth login --cred-file=/home/ubuntu/.config/gcloud/cross-cloud-client-config.json
    ```

    !!! abstract "Terminal Output"
        ```bash
        You are already authenticated with 'nymeria-cross-cloud-sa@[YOUR_GOOGLE_PROJECT_ID].iam.gserviceaccount.com'. Do you wish to proceed and overwrite existing credentials?

        Do you want to continue (Y/n)? Y

        Authenticated with external account credentials for: [nymeria-cross-cloud-sa@[YOUR_GOOGLE_PROJECT_ID].iam.gserviceaccount.com].
        ```

1. Run the following command to configure the `gcloud` command line interface to use your Google Cloud project. Enter `Y` to overwrite the existing project configuration.

    ```bash
    gcloud config set project $GCP_PROJECT_ID
    ```

    !!! abstract "Terminal Output"
        ```bash
        WARNING: You do not appear to have access to project [YOUR_GOOGLE_PROJECT_ID] or it does not exist. Are you sure you wish to set property [core/project] to [YOUR_GOOGLE_PROJECT_ID]?

        Do you want to continue (Y/n)?  Y

        Updated property [core/project].
        ```

1. Run the following `gsutil` command to access the GCS API. This command will automatically use the `cross-cloud-client-config.json` to authenticate to the workload identity pool, impersonate the `nymeria-cross-cloud-sa` service account, and download the object from the bucket.

    ```bash
    gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-workload-identity.png
    ls -la ~/gcp-workload-identity.png
    ```

    !!! abstract "Terminal Output"
        ```bash
        Copying gs://nymeria-cross-cloud-e9zwi7h7/gcp-workload-identity.png...
        / [1 files][155.7 KiB/155.7 KiB]
        Operation completed over 1 objects/155.7 KiB.

        -rw-rw-r-- 1 ubuntu ubuntu 159450 Sep 21 17:43 /home/ubuntu/gcp-workload-identity.png
        ```

## Next Steps

!!! success "Google Cloud Workload Identity"
    With this configuration, we have successfully killed the Google cloud long-lived service account key. The Nymeria virtual machine is now using its native identity token (JWT) to impersonate the Google Cloud service account and access to the GCS API.

Congratulations, you have completed the Nymeria workshop. Next, move on to the [Teardown](./teardown.md) section to destroy the resources you created during the workshop.
