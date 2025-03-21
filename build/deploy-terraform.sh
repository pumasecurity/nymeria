#!/bin/bash
set -e
CURRENT_DIR=$PWD

# set TF vars for deploy
export TF_VAR_resource_group_name=$ARM_RESOURCE_GROUP_NAME
export TF_VAR_azure_virtual_machine_managed_identity_id=$AZURE_VIRTUAL_MACHINE_USER_IDENTITY_ID

export TF_VAR_aws_default_region=$AWS_DEFAULT_REGION
export TF_VAR_aws_access_key_id=$AZURE_VM_AWS_ACCESS_KEY_ID
export TF_VAR_aws_secret_access_key=$AZURE_VM_AWS_SECRET_ACCESS_KEY
export TF_VAR_aws_cross_cloud_role_arn=$AZURE_VM_AWS_ROLE_ARN
export TF_VAR_aws_s3_bucket_id=$AWS_S3_BUCKET

export TF_VAR_google_cloud_project_id=$GCP_PROJECT_ID
export TF_VAR_google_cloud_service_account_key=$AZURE_VM_GOOGLE_SERVICE_ACCOUNT_KEY
export TF_VAR_google_cloud_workload_identity_client_configuration=$GCP_WORKLOAD_IDENTITY_CLIENT_CONFIGURATION
export TF_VAR_gcs_bucket_id=$GCS_BUCKET

echo "Deploying 04_gh_action resources..."
cd "${CURRENT_DIR}/src/virtual_machines/04_gh_action"
terraform init --backend-config="storage_account_name=$ARM_STORAGE_ACCOUNT_NAME" --backend-config="resource_group_name=$ARM_RESOURCE_GROUP_NAME"
terraform plan -out tf.plan
terraform apply -auto-approve tf.plan

cd "${CURRENT_DIR}"
