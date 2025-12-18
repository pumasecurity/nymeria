# Long Lived Credentials

Explore Nymeria's long lived credentials for each cloud provider: Azure, AWS, and Google Cloud. Use each long lived credential to access resources in each cloud provider.

## GitHub Action Credentials

From the GitHub Action called *Long Lived Credentials*, find the Azure tenant id, client id, and client secret values in the log output.

!!! warning "Stolen Credentials"
    Running the `long-lived-credentials` action will purposely expose an Azure client id and client secret in the GitHub Actions logs. The service principal  permissions only have the *Reader* role on the `nymeria-workshop` resource group, which currently has no data to exfiltrate. However, these credentials are real and should be immediately deleted at the end of this to prevent exposure. You can skip this section if you are not comfortable with this risk.

1. In your GitHub repository, navigate to the *Actions* tab. Then, click on the *I understand my workflows, go ahead and enable them.* button.

    ![](./img/gh-actions.png)

1. Click on the *Long Lived Credentials* workflow. Then, click on the *Run workflow* button to start the workflow on the `main` branch.

    ![](./img/gh-action-ll.png)

1. Select the completed run of the *Long Lived Credentials* action to view the jobs.

    ![](./img/gh-action-ll-jobs.png)

1. Select the *Apply Terraform* job to view the steps.

    ![](./img/gh-action-ll-tf.png)

1. Expand the *Azure Login* step to find the Azure tenant id, client id, and client secret values in the log output.

    !!! abstract "Console Output"
        ```bash
        Run azure/login@v1.4.6
        with:
          creds: ***"clientId":"[your-client-id]","clientSecret":"[your-client-secret]","subscriptionId":"[your-subscription-id]","tenantId":"[your-tenant-id]"***
          enable-AzPSSession: false
          environment: azurecloud
          allow-no-subscriptions: false
          audience: api://AzureADTokenExchange
        ```

1. These long-lived credentials are being used to authenticate to the Azure subscription. Observe the GitHub Action also shows a *Note* suggesting that we use a a federated credential to use OIDC based authentication.

    !!! abstract "Console Output"
        ```bash
        Note: Azure/login action also supports OIDC login mechanism. Refer https://github.com/azure/login#configure-a-service-principal-with-a-federated-credential-to-use-oidc-based-authentication for more details.
        Login successful.
        ```

### Azure Service Principal Secret

Use the long-lived stolen client id and secret values to authenticate to the Azure tenant.

1. Browse to the [Azure Portal](https://portal.azure.com/){: target="_blank" rel="noopener"} open **Cloud Shell** again.

    ![](./img/az-portal.png)

1. Start by running the `az ad signed-in-user show` command. Observe you are signed into the Terminal under your personal account.

    ```bash
    az ad signed-in-user show
    ```

    !!! abstract "Terminal Output"
        ```bash
        {
          "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",
          "businessPhones": [],
          "displayName": "Last Name, First Name,
          "givenName": "First Name",
          "id": "2e164a5a-1ebd-4f3e-ab84-18165db3e826",
          "jobTitle": "Hacker",
          "mail": "user@pumasecurity.io",
          "mobilePhone": null,
          "officeLocation": null,
          "preferredLanguage": null,
          "surname": "Last Name",
          "userPrincipalName": "user@pumasecurity.io"
        }
        ```

1. Set the following environment variables to the stolen service principal credentials.

    ```bash
    ARM_TENANT_ID=[STOLEN_TENANT_ID]
    ARM_CLIENT_ID=[STOLEN_CLIENT_ID]
    ARM_CLIENT_SECRET=[STOLEN_CLIENT_SECRET]
    ARM_SUBSCRIPTION_ID=[STOLEN_SUBSCRIPTION_ID]
    ```

1. Use the stolen service principal credentials to authenticate to the Azure tenant and set the subscription.

    ```bash
    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
    az account set --subscription $ARM_SUBSCRIPTION_ID
    ```

1. The following command will list the resource groups that the service principal has access to: `nymeria-workshop`.

    ```bash
    az group list -o table
    ```

    !!! abstract "Terminal Output"
        ```bash
        Name              Location    Status
        ----------------  ----------  ---------
        nymeria-workshop  eastus      Succeeded
        ```

1. The following command will list the storage accounts in the `nymeria-workshop` resource group. The output will confirm you are able to view the storage account containing the Nymeria Terraform state data.

    ```bash
    az storage account list -g nymeria-workshop -o table --query "[].{resourceGroup:resourceGroup, name:name}"
    ```

    !!! abstract "Terminal Output"
        ```bash
        ResourceGroup     Name
        ----------------  -----------------
        nymeria-workshop  terraform9s6ogn1e
        ```

1. Now that we have proven the stolen credentials work, restart the Azure Cloud Shell to re-authenticate under your personal account.

    ![](./img/az-cloudshell-restart.png)

1. Run the following command to delete the compromised service principal from your Azure subscription.

    ```bash
    LONG_LIVED_APP_ID=$(az ad app list | jq -r '.[] | select(.displayName=="github-creds-ad-app").id')
    az ad app delete --id $LONG_LIVED_APP_ID
    ```

1. Go back to the GitHub repository and delete the run that contained the stolen credentials.

    ![](./img/gh-action-ll-delete.png)

!!! success "Credential Containment"
    Congratulations, you have successfully contained the stolen Azure credentials. Imagine doing this at scale across an enterprise each time a credential is accidentally leaked. Workload identity federation is powerful way to avoid the need for long lived credentials.

## Nymeria Virtual Machine

Start hunting for long-lived AWS and Google cloud credentials on the Nymeria virtual machine. To do this, you will first need to connect to the Nymeria virtual machine over SSH. The private SSH key is stored in a Terraform output parameter called `ssh_private_key` from the `04_gh_action` deployment. Using the Azure Cloud Shell, store this output in the `~/.ssh/nymeria.pem` file.

1. Run the following commands in the Azure Cloud Shell to authenticate to the Terraform state storage account.

    ```bash
    cd ~/clouddrive/nymeria/src/virtual_machines/01_azure_init/
    ARM_RESOURCE_GROUP_NAME=$(terraform output --json | jq -r '.resource_group_name.value')
    ARM_STORAGE_ACCOUNT_NAME=$(terraform output --json | jq -r '.terraform_storage_account_name.value')
    cd ~/clouddrive/nymeria/src/virtual_machines/04_gh_action/
    terraform init --backend-config="storage_account_name=$ARM_STORAGE_ACCOUNT_NAME" --backend-config="resource_group_name=$ARM_RESOURCE_GROUP_NAME"
    ```

1. Read the `ssh_private_key` output parameter and store the private key in the `~/clouddrive/.ssh/nymeria.pem` file.

    ```bash
    mkdir -p ~/.ssh
    terraform output --json | jq -r '.ssh_private_key.value' > ~/.ssh/nymeria.pem
    chmod 400 ~/.ssh/nymeria.pem
    ```

1. Use the `ssh_private_key` output parameter to connect to the Nymeria virtual machine over SSH.

    ```bash
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

### AWS Access Key

Inspect the `~/.aws/` directory for configuration files containing long-lived AWS credentials.

1. List the files in the `~/.aws/` directory. Do you see a file that might contain long-lived credentials?

    ```bash
    ls -la ~/.aws/
    ```

    !!! abstract "Terminal Output"
        ```bash
        total 20
        drwxr-xr-x 2 ubuntu ubuntu 4096 Sep 19 22:38 .
        drwxr-x--- 6 ubuntu ubuntu 4096 Sep 20 16:49 ..
        -rw-r--r-- 1 root   root     67 Sep 19 22:38 config
        -rw-r--r-- 1 root   root    121 Sep 19 22:38 credentials
        -rw-r--r-- 1 root   root    174 Sep 19 22:38 get-resources.sh
        ```

1. Use the `cat` command to view the long-lived AWS credentials.

    ```bash
    cat ~/.aws/credentials
    ```

    !!! abstract "Terminal Output"
        ```bash
        [cross-cloud]
        aws_access_key_id = [STOLEN_AWS_ACCESS_KEY_ID]
        aws_secret_access_key = [STOLEN_AWS_SECRET_ACCESS_KEY]
        ```

1. Set the `AWS_PROFILE` environment variable to `cross-cloud` and use the `aws sts get-caller-identity` command to test the credentials validity.

    ```bash
    export AWS_PROFILE=cross-cloud
    aws sts get-caller-identity
    ```

    !!! abstract "Terminal Output"
        ```bash
        {
            "UserId": "AIDAEXAMPLEID",
            "Account": "123456789012",
            "Arn": "arn:aws:iam::123456789012:user/nymeria-azure-vm"
        }
        ```

1. Review the environment variables pre-populated into the `~/.aws/get-resources.sh` script. The values include the unique AWS S3 bucket with a Nymeria image.

    ```bash
    cat ~/.aws/get-resources.sh
    ```

    !!! abstract "Terminal Output"
        ```bash
        export AWS_S3_BUCKET_ID=nymeria-cross-cloud-abc123
        export AWS_CROSS_CLOUD_ROLE_ARN=arn:aws:iam::123456789012:role/nymeria-azure-vm-role
        export AWS_DEFAULT_REGION=us-east-2
        ```

1. Source the environment variables in the `~/.aws/get-resources.sh` script and verify the bucket name is populated in the `AWS_S3_BUCKET_ID` environment variable.

    ```bash
    source ~/.aws/get-resources.sh 
    echo $AWS_S3_BUCKET_ID
    ```

    !!! abstract "Terminal Output"
        ```bash
        nymeria-cross-cloud-abc123
        ```

1. Run the `aws s3 cp` command to download the Nymeria image from the S3 bucket using the stolen long-lived credentials.

    ```bash
    aws s3 cp s3://$AWS_S3_BUCKET_ID/aws-workload-identity.png ~/aws-long-lived-credentials.png
    ls -la ~/aws-long-lived-credentials.png
    ```

    !!! abstract "Terminal Output"
        ```bash
        download: s3://nymeria-cross-cloud-iulqhgnx/aws-workload-identity.png to ./aws-long-lived-credentials.png
        -rw-rw-r-- 1 ubuntu ubuntu 156686 Sep 19 00:25 /home/ubuntu/aws-long-lived-credentials.png
        ```

### Google Cloud Service Account Key

Inspect the `~/.config/gcloud/` directory for configuration files containing long-lived Google Cloud credentials.

1. List the files in the `~/.config/gcloud/` directory. Do you see a file that might contain long-lived credentials?

    ```bash
    ls -la ~/.config/gcloud/
    ```

    !!! abstract "Terminal Output"
        ```bash
        total 20
        drwxr-xr-x 2 ubuntu ubuntu 4096 Sep 19 22:38 .
        drwxr-xr-x 3 root   root   4096 Sep 19 22:38 ..
        -rw-r--r-- 1 root   root    799 Sep 19 22:38 cross-cloud-client-config.json
        -rw-r--r-- 1 root   root   2387 Sep 19 22:38 cross-cloud-key.json
        -rw-r--r-- 1 root   root     89 Sep 19 22:38 get-resources.sh
        ```

1. Use the `cat` command to view the long-lived GCP service account key.

    ```bash
    cat ~/.config/gcloud/cross-cloud-key.json
    ```

    !!! abstract "Terminal Output"
        ```json
        {
            "type": "service_account",
            "project_id": "[YOUR_GOOGLE_PROJECT_ID]",
            "private_key_id": "662b8b4b471ac0b823d5b0a8206a185f6203cf55",
            "private_key": "-----BEGIN PRIVATE KEY-----
            ...[snipped for brevity]
        }
        ```

1. Review the environment variables pre-populated into the `~/.config/gcloud/get-resources.sh` script. The values include the unique GCS bucket with a Nymeria image.

    ```bash
    cat ~/.config/gcloud/get-resources.sh
    ```

    !!! abstract "Terminal Output"
        ```bash
        export GCS_BUCKET_ID=nymeria-cross-cloud-abc123
        export GCP_PROJECT_ID=[YOUR_GCP_PROJECT_ID]
        ```

1. Source the environment variables in the `~/.config/gcloud/get-resources.sh` script and verify the bucket name is populated in the `AWS_S3_BUCKET_ID` environment variable.

    ```bash
    source ~/.config/gcloud/get-resources.sh
    echo $GCS_BUCKET_ID
    ```

    !!! abstract "Terminal Output"
        ```bash
        nymeria-cross-cloud-abc123
        ```

1. Run the `gcloud auth activate-service-account` command to configure the `gcloud` CLI to use the stolen long-lived credentials.

    ```bash
    gcloud auth activate-service-account --key-file=/home/ubuntu/.config/gcloud/cross-cloud-key.json
    ```

    !!! abstract "Terminal Output"
        ```bash
        Activated service account credentials for: [nymeria-cross-cloud-sa@[YOUR_GOOGLE_PROJECT_ID].iam.gserviceaccount.com]
        ```

1. Run the `gsutil` command to download the Nymeria image from the GCS bucket using the stolen long-lived credentials.

    ```bash
    gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-long-lived-credential.png
    ls -la ~/gcp-long-lived-credential.png
    ```

    !!! abstract "Terminal Output"
        ```bash
        Copying gs://nymeria-cross-cloud-e9zwi7h7/gcp-workload-identity.png...
        / [1 files][155.7 KiB/155.7 KiB]
        -rw-rw-r-- 1 ubuntu ubuntu 159450 Sep 20 18:02 /home/ubuntu/gcp-long-lived-credential.png
        ```

## Next Steps

!!! danger "Long-Lived Credential Exploitation"
    Congratulations, you have successfully stolen and used long-lived credentials to gain access to Azure, AWS, and GCP resources. These long-lived credentials will be destroyed using the [Nymeria Teardown](./teardown.md) steps at the end of the workshop.

Next, move on to the [Azure Federation](./azure.md) section to learn how to use Azure Workload Identity Federation to avoid the need for long-lived client secrets.
