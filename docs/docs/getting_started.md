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

### Azure GitHub Secret

Configure the required GitHub Action secret for the Nymeria repository to deploy resources to your Azure subscription.

1. Read the Terraform output and copy the entire output value onto the clipboard:

    ```bash
    terraform output --json
    ```

    !!! abstract "Terminal Output"
        ```
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
            "value": "__redacted__"
          },
          "terraform_state_storage_account_name": {
            "sensitive": false,
            "type": "string",
            "value": "__redacted__"
          }
        }
        ```

1. Browse to your GitHub repository's **Settings**.

1. In the left navigation, press the **Secrets and variables > Actions** menu item.

1. Press the **New repository secret** button.

1. Enter the following values for the new secret:

    - **Name**: AZURE_BOOTSTRAP

    - **Secret**: Paste the value of the `azure_subscription_id`

1. Press the **Add Secret** button

## AWS Account

### AWS Bootstrap

### AWS GitHub Secret

## Google Cloud Project

### Google Cloud Bootstrap

### Google Cloud Secret
