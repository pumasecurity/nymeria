# Cloud Functions

This directory contains a minimally-viable codebase for cloud functions that upload files to the cloud storage services of the other providers using the following Workload Identity Federation integrations:

- Azure uploading files to AWS S3 (by establishing trust via JWTs)
- Azure uploading files to Google Cloud Storage (by establishing trust via JWTs)
- Google Cloud uploading files to AWS S3 (by establishing trust via JWTs)
- Google Cloud uploading files to Azure Storage (by establishing trust via JWTs)
- AWS uploading files to Google Cloud Storage ([by creating a Version 4 AWS Signature, sending it to the Google Cloud Security Token Service, and exchanging it for a short-lived OIDC token](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#rest))

As Azure does not support an AWS Sigv4 exchange process like Google Cloud does, this codebase does not provide a solution for AWS uploading files to Azure Storage.

## Usage

### Deploy Infrastructure

```bash
aws configure
az login
gcloud auth login
export TF_VAR_google_cloud_project_id=<Replace this block with your Google Cloud Project ID>

cd ./functions/nodejs/upload
npm ci

cd ../../../terraform
terraform init
terraform apply --auto-approve
```

### Invoking Functions

Make sure you have deployed the infrastructure and are still in a terminal session that is authenticated to the cloud providers. Then, run one of the following:

#### Upload Files From AWS

```bash
cd ./terraform
export AWS_FUNCTION_URL=$(terraform output --json | jq -r '.aws_function_url.value')
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$AWS_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "from_aws", "content": "test"}'
```

#### Upload Files From Azure

```bash
cd ./terraform
export AZURE_FUNCTION_URL="https://$(terraform output --json | jq -r '.azure_function_host.value')/api/upload"
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$AZURE_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "from_azure", "content": "test"}'
```

#### Upload Files From Google Cloud

```bash
cd ./terraform
export GOOGLE_FUNCTION_URL=$(terraform output --json | jq -r '.google_function_url.value')
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$GOOGLE_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "from_google", "content": "test"}'
```

### Teardown

Make you are still in a terminal session that is authenticated to the cloud providers. Then, run one of the following:

```bash
terraform destroy --auto-approve
```

## References

- These example functions are based on content from SANS Institute [SEC510: Cloud Security Engineering and Controls](https://www.sans.org/cyber-security-courses/cloud-security-engineering-controls). SEC510 provides cloud security analysts, engineers, and researchers with practical security controls that can help organizations reduce their attack surface and prevent security incidents from becoming breaches. To learn more, please visit [here](https://www.sans.org/cyber-security-courses/cloud-security-engineering-controls), review the syllabus, and click the **Course Demo** button for a free ~1 hour module.

- Some of the code for these functions were adapted by the [Serverless Prey project](https://github.com/pumasecurity/serverless-prey), a collection of cloud functions that, once launched to a cloud environment and invoked, establish a TCP reverse shell, enabling the user to introspect the underlying container.
