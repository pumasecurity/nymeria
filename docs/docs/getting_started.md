# Getting Started

## Requirements

Please sign up for a personal account with the following cloud services before starting the workshop:

- [x] GitHub Account
- [x] Azure Subscription
- [x] AWS Account
- [x] Google Cloud Project

## GitHub Repository Configuration

Start by forking Puma Security's [Nymeria Workload Identity Repository](https://github.com/pumasecurity/nymeria) into your personal GitHub organization.

1. Sign in to your GitHub account.

1. Browse to the Puma Security [Nymeria Workload Identity Repository](https://github.com/pumasecurity/nymeria).

1. In the top right-hand corner, press the **Fork** button to fork the repository to your personal GitHub account.

1. Copy the clone URL onto the clipboard.

## Azure Subscription

### Azure Bootstrap

Complete the following steps to create the resources required to authenticate the Nymeria GitHub Action to your Azure subscription.

1. Sign into the [Azure Portal](https://portal.azure.com/) and press the **Cloud Shell** icon next to the search box.

1. Run the following commands to clone your `nymeria` repository into the Azure cloud drive.

    ```bash
    cd ~/clouddrive
    git clone [ENTER_YOUR_CLONE_URL]
    ```

1. Change the directory to the `~/clouddrive/nymeria/src/01_azure_init` directory.

    ```bash
    cd ~/clouddrive/nymeria/src/01_azure_init
    ```

1. Apply the Terraform configuration to bootstrap your Azure subscription with both long-lived credentials and the workload identity resources.

    ```bash
    export TF_VAR_github_repository=nymeria
    export TF_VAR_github_organization=[ENTER_YOUR_GITHUB_ORGANIZATION]
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

1. Terraform should confirm the successful creation of the workload identity resources.

    !!! abstract "Terminal Output"
        ```bash
        Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

        Outputs:

        azure_subscription_id = <sensitive>
        azure_tenant_id = <sensitive>
        azure_virtual_machine_user_identity_id = "__redacted__"
        github_service_principal_client_id = <sensitive>
        github_service_principal_client_secret = <sensitive>
        resource_group_name = "nymeria-federated-identity"
        terraform_state_storage_account_name = "terraformmlgxt9hl"
        ```

### Azure GitHub Secret

Configure the required GitHub Action secret for the Nymeria repository to deploy resources to your Azure subscription.

1. Read the Terraform output and copy the entire output value onto the clipboard:

    ```bash
    terraform output --json
    ```

    !!! abstract "Terminal Output"
        ```json
        {
          "azure_subscription_id": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "azure_tenant_id": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "azure_virtual_machine_user_identity_id": {
            "sensitive": false,
            "type": "string",
            "value": "__redacted__"
          },
          "github_service_principal_client_id": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "github_service_principal_client_secret": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "resource_group_name": {
            "sensitive": false,
            "type": "string",
            "value": "nymeria-federated-identity"
          },
          "terraform_state_storage_account_name": {
            "sensitive": false,
            "type": "string",
            "value": "terraformznoypqbp"
          }
        }
        ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: `AZURE_BOOTSTRAP`

    - **Secret**: Paste the JSON Terraform output

1. Press the **Add Secret** button.

## AWS Account

### AWS Bootstrap

Complete the following steps to create the resources required for the Azure virtual machine to authenticate your AWS account.

1. Sign into the [AWS Web Console](https://console.aws.amazon.com/) and press the **Cloud Shell** icon next to the search box.

1. Unlike Azure and Google Cloud, the AWS CloudShell does not come with Terraform preinstalled. You will need to install Terraform before you can initialize your AWS account.

  ```bash
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  mkdir ~/bin
  ln -s ~/.tfenv/bin/* ~/bin/
  tfenv install 1.4.5
  tfenv use 1.4.5
  terraform --version
  ```

1. Run the following commands to clone your `nymeria` repository into the AWS cloud drive.

    ```bash
    cd ~/clouddrive
    git clone [ENTER_YOUR_CLONE_URL]
    ```

1. Change the directory to the `~/clouddrive/nymeria/src/02_aws_init` directory.

    ```bash
    cd ~/clouddrive/nymeria/src/02_aws_init
    ```

1. Apply the Terraform configuration to bootstrap your Azure subscription with both long-lived credentials and the workload identity resources.

    ```bash
    export TF_VAR_azure_tenant_id=[ENTER_YOUR_AZURE_TENANT_ID]
    export TF_VAR_azure_virtual_machine_managed_identity_principal_id=[AZURE_VIRTUAL_MACHINE_USER_IDENTITY_PRINCIPAL_ID]
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

1. Terraform should confirm the successful creation of the workload identity resources.

    !!! abstract "Terminal Output"
        ```bash
        Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

        Outputs:

        aws_s3_bucket = "cross-cloud-yh831o00"
        azure_vm_aws_role_arn = "arn:aws:iam::111111111111:role/nymeria-azure-vm-role"
        azure_vm_aws_access_key_id     = (sensitive value)
        azure_vm_aws_secret_access_key = (sensitive value)
        aws_default_region = us-east-2
        ```

### AWS GitHub Secret

1. From the AWS CloudShell terminal, run the following command to display the Terraform output. Copy the entire output value onto the clipboard:

    ```bash
    terraform output --json
    ```

    !!! abstract "Terminal Output"
        ```json
        {
          "aws_s3_bucket": {
            "sensitive": false,
            "type": "string",
            "value": "nymeria-cross-cloud-yh831o00"
          },
          "azure_vm_aws_access_key_id": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "azure_vm_aws_role_arn": {
            "sensitive": false,
            "type": "string",
            "value": "arn:aws:iam::111111111111:role/nymeria-azure-vm-role"
          },
          "azure_vm_aws_secret_access_key": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          }
        }
        ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: `AWS_BOOTSTRAP`

    - **Secret**: Paste the JSON Terraform output

1. Press the **Add Secret** button.

## Google Cloud Project

### Google Cloud Bootstrap

Complete the following steps to create the resources required for the Azure virtual machine to authenticate your Google cloud project.

1. Sign into the [Google Cloud Web Console](https://console.cloud.google.com/) and press the **Cloud Shell** icon next to the search box.

1. Run the following commands to clone your `nymeria` repository into the Google cloud drive.

    ```bash
    cd ~/clouddrive
    git clone [ENTER_YOUR_CLONE_URL]
    ```

1. Change the directory to the `~/clouddrive/nymeria/src/03_gcp_init` directory.

    ```bash
    cd ~/clouddrive/nymeria/src/03_gcp_init
    ```

1. Apply the Terraform configuration to bootstrap your Azure subscription with both long-lived credentials and the workload identity resources.

    ```bash
    export TF_VAR_project_id=[ENTER_YOUR_GOOGLE_PROJECT_ID]
    export TF_VAR_azure_virtual_machine_managed_identity_principal_id=[AZURE_VIRTUAL_MACHINE_USER_IDENTITY_PRINCIPAL_ID]

    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

1. Terraform should confirm the successful creation of the workload identity resources.

    !!! abstract "Terminal Output"
        ```bash
        Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

        Outputs:

        azure_vm_google_service_account_key = <sensitive>
        gcs_bucket = "nymeria-cross-cloud-n26pm4d6"
        workload_identity_client_configuration = ...
        ```

### Google Cloud GitHub Secret

1. From the Google CloudShell terminal, run the following command to display the Terraform output. Copy the entire output value onto the clipboard:

    ```bash
    terraform output --json
    ```

    !!! abstract "Terminal Output"
        ```json
        {
          "azure_vm_google_service_account_key": {
            "sensitive": true,
            "type": "string",
            "value": "__redacted__"
          },
          "gcs_bucket": {
            "sensitive": false,
            "type": "string",
            "value": "nymeria-cross-cloud-n26pm4d6"
          },
          "workload_identity_client_configuration": {
            "sensitive": false,
            "type": "string",
            "value": "..."
          }
        }
        ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: `GCP_BOOTSTRAP`

    - **Secret**: Paste the JSON Terraform output

1. Press the **Add Secret** button.
