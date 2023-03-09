# Workload Identity Workshop

## GitHub Repository Configuration

Start by forking Puma Security's [Nymeria Workload Identity Repository](https://github.com/pumasecurity/nymeria) into your personal GitHub organization.

1. Sign in to your GitHub account.

1. Browse to the Puma Security [Nymeria Workload Identity Repository](https://github.com/pumasecurity/nymeria).

1. In the top right-hand corner, press the **Fork** button to fork the repository to your personal GitHub account.

1. Copy the clone URL onto the clipboard.

## Bootstrap

Sign into the [Azure Portal](https://portal.azure.com/) and connect to a **Cloud Shell** section. Then, clone your Nymeria Workload Identity Repository fork to the *clouddrive* directory.

1. Sign into the [Azure Portal](https://portal.azure.com/) and press the **Cloud Shell** icon next to the search box.

1. Run the following command to clone your Nymeria Workload Identity Repository.

    ```bash
    cd ~/clouddrive
    git clone [ENTER_YOUR_CLONE_URL]
    ```

1. Change the directory to the `~/clouddrive/nymeria/src/bootstrap` directory.

    ```bash
    cd ~/clouddrive/nymeria/src/bootstrap
    ```

1. Apply the Terraform configuration to bootstrap your Azure subscription with the appropriate workload identity resources.

    ```bash
    export TF_VAR_github_repository=nymeria
    export TF_VAR_github_organization=[ENTER_YOUR_GITHUB_ORGANIZATION]
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

1. Terraform should confirm the successful creation of the workload identity resources.

    ```bash
    Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

    Outputs:

    azure_resource_group_name = "federated-identity"
    azure_subscription_id = <sensitive>
    azure_tenant_id = <sensitive>
    github_service_principal_client_id = <sensitive>
    github_service_principal_client_secret = <sensitive>
    ```

## GitHub Secrets Configuration

Configure the required GitHub Action secrets for the Nymeria repository to deploy the workload identity resources across the AWS, Azure, and Google Clouds.

### Azure Subscription

1. Read the value of the `azure_subscription_id` output and copy the value onto the clipboard:

    ```bash
    terraform output --json | jq -r '.azure_subscription_id.value'
    ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: ARM_SUBSCRIPTION_ID

    - **Secret**: Paste the value of the `azure_subscription_id`

1. Press the **Add Secret** button

### Azure Tenant

1. Read the value of the `azure_tenant_id` output and copy the value onto the clipboard:

    ```bash
    terraform output --json | jq -r '.azure_tenant_id.value'
    ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: ARM_TENANT_ID

    - **Secret**: Paste the value of the `azure_subscription_id`

1. Press the **Add Secret** button

### Azure Service Principal Client Id

1. Read the value of the `github_service_principal_client_id` output and copy the value onto the clipboard:

    ```bash
    terraform output --json | jq -r '.github_service_principal_client_id.value'
    ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: ARM_CLIENT_ID

    - **Secret**: Paste the value of the `azure_subscription_id`

1. Press the **Add Secret** button

### Azure Service Principal Secret

1. Read the value of the `github_service_principal_client_secret` output and copy the value onto the clipboard:

    ```bash
    terraform output --json | jq -r '.github_service_principal_client_secret.value'
    ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: ARM_CLIENT_SECRET

    - **Secret**: Paste the value of the `github_service_principal_client_secret`

1. Press the **Add Secret** button

### GitHub Action

### AWS Workload Identity Federation

Run the following commands from the Azure VM to obtain an OpenID Connect JWT.

```bash
AZURE_JWT=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=api://nymeria-workload-identity" -H "Metadata: true" | jq -r '.access_token')
```

Validate the token is issues by the trusted Azure identity provider and the subject is the virtual machine's managed service identity.

```bash
jwt_decode "$AZURE_JWT"
```

Use the trusted OpenID Connect token to assume a role in the AWS account.

```bash
export $(aws sts assume-role-with-web-identity --region us-east-2 --role-arn "$AWS_ROLE_ARN" --role-session-name "federated-identity-azure-demo" --web-identity-token "$AZURE_JWT" --output text --query "[['AWS_ACCESS_KEY_ID',Credentials.AccessKeyId],['AWS_SECRET_ACCESS_KEY',Credentials.SecretAccessKey],['AWS_SESSION_TOKEN',Credentials.SessionToken]][*].join(\`=\`,@)")

aws sts get-caller-identity --region us-east-2

aws s3 cp --region us-east-2 s3://cross-cloud-kpgbfc1y/aws-workload-identity.png ~/aws-workload-identity.png
```

### Google Cloud Workload Identity Federation

Use the token to authenticate to Google Cloud:

```
gcloud auth login --cred-file=/home/ubuntu/gcp-azure-cross-cloud.json
```

Copy the object from GCS:

```
gsutil cp gs://cross-cloud-xb0rr25x/gcp-workload-identity.png ~/
```
