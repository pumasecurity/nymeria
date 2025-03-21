# Kubernetes Workload Identity Federation

The Kubernetes Workload Identity Federation creates cross-cluster identity federation trust between Kubernetes service accounts running in AWS EKS, Azure AKS, and Goolge GKE. The federation trust allows a Kubernetes service account in all three clusters to access data stored in all three cloud storage services (S3, Azure Storage, and Google Cloud Storage). All in - a total of 9 cross-cloud trust relationships are created.

## Deploying Kubernetes Nymeria

You will need an AWS, Azure, and GCP project for this deployment. The following assumes that you have already authenticated your command line interface (`aws`, `az`, and `gcloud`) to each of the three cloud providers.

### AWS

Set your profile and run `aws sts get-caller-identity` to verify that you are authenticated.

```bash
export AWS_PROFILE=<your-aws-profile>
aws sts get-caller-identity
```

### Azure

Run `az login` and set the subscription that you want to use

```bash
az login
az account set --subscription <your-azure-subscription-id>
```

### Google Cloud

Run `gcloud auth application-default login` and set the project that you want to use

```bash
gcloud auth application-default login
gcloud config set project <your-gcp-project-id>
```

### Terraform Deployment

Run, run the following commands to deploy the infrastructure:

```bash
export TF_VAR_aws_active=true
export TF_VAR_aws_region=us-west-1

export TF_VAR_azure_active=true
export TF_VAR_azure_subscription_id=$(az account show | jq -r '.id')
export TF_VAR_azure_location=eastus2

export TF_VAR_gcp_active=true
export TF_VAR_gcp_region=us-west2
export TF_VAR_gcp_project_id=<your-gcp-project-id>

terraform plan
terraform apply -auto-approve
```
