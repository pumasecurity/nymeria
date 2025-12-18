# AWS Outbound Identity Federation

As of re:invent 2025, AWS now supports outbound identity federation to external identity providers, including Azure managed identities and Google Cloud service accounts. This allows AWS IAM roles to assume identities in other cloud providers using a token issued by the AWS account's outbound OIDC identity provider.

To set up AWS outbound identity federation with an Azure managed identity, follow these steps:

```bash
cd ~/nymeria/src/virtual_machines/01_azure_init/
export TF_VAR_azure_resource_group_name=$(terraform output --json | jq -r '.resource_group_name.value')
export TF_VAR_azure_storage_account_name=$(terraform output --json | jq -r '.terraform_storage_account_name.value')
export TF_VAR_azure_managed_identity_id=$(terraform output --json | jq -r '.azure_virtual_machine_user_identity_id.value')
export TF_VAR_azure_managed_identity_client_id=$(terraform output --json | jq -r '.azure_virtual_machine_user_identity_client_id.value')
export TF_VAR_azure_tenant_id=$(terraform output --json | jq -r '.azure_tenant_id.value')
cd ~/nymeria/src/virtual_machines/05_aws_azure/
terraform init
terraform plan
terraform apply -auto-approve
```

Then, use the outputs from the previous modules to configure the Azure managed identity to allow the AWS IAM role to login to the tenant.

```bash
export TF_VAR_aws_iam_role_arn=$(terraform output --json | jq -r '.iam_role_arn.value')
export TF_VAR_aws_account_issuer=$(terraform output --json | jq -r '.account_issuer_endpoint.value')
cd ~/nymeria/src/virtual_machines/06_azure_aws_trust/
terraform init
terraform plan
terraform apply -auto-approve
```

Now, we can connect to the AWS instance and test the managed identity federation.

```bash
cd ~/nymeria/src/virtual_machines/05_aws_azure/
export AWS_INSTANCE_ID=$(terraform output --json | jq -r '.nymeria_instance_id.value')
aws ssm start-session --target $AWS_INSTANCE_ID
```

Run the following command to generate an OIDC token that can be used by the `api://AzureADTokenExchange` audience.

```bash
aws sts get-web-identity-token --audience api://AzureADTokenExchange --signing-algorithm RS256 --duration-seconds 300
```

This will return a JSON object containing the `WebIdentityToken`. Use the `jwt_decode` function defined in the `.bash_aliases` file to decode the token and verify its contents.

```bash
JWT=$(aws sts get-web-identity-token --audience api://AzureADTokenExchange --signing-algorithm RS256 --duration-seconds 300 | jq -r '.WebIdentityToken')
jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $JWT
```

Next, use the token to sign in to the Azure tenant.

```bash
source ~/.azure/get-resources.sh
az login --service-principal --tenant $AZURE_TENANT_ID --username $AZURE_MANAGED_IDENTITY_CLIENT_ID --federated-token $JWT
```

Query the storage data account and download the file.

```bash
sh-5.2$ az storage blob list --auth-mode login --account-name $AZURE_STORAGE_ACCOUNT --container-name assets | jq '.[].name'
az storage blob download --auth-mode login --account-name $AZURE_STORAGE_ACCOUNT --container-name assets --name azure-workload-identity.png --file azure-workload-identity.png
cat azure-workload-identity.png
```
