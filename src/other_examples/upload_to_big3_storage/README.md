# Upload to Big 3 Storage Services

This directory contains a minimally-viable codebase for cloud functions uploading files to cloud storage using the following Workload Identity Federation integrations:

- Azure uploading files to AWS S3 (by establishing trust via JWTs)
- Azure uploading files to Google Cloud Storage (by establishing trust via JWTs)
- Google Cloud uploading files to AWS S3 (by establishing trust via JWTs)
- Google Cloud uploading files to Azure Storage (by establishing trust via JWTs)
- AWS uploading files to Google Cloud Storage ([by creating a Version 4 AWS Signature, sending it to the Google Cloud Security Token Service, and exchanging it for a short-lived OIDC token](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#rest))

As Azure does not support an AWS Sigv4 exchange process like Google Cloud does, this codebase does not provide a solution for AWS uploading files to Azure Storage.

## Usage

### Deploy

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

TODO: Make sure providers are optional
TODO: Maybe somehow specify code directory so we can support other languages.

### Invoking Functions

#### From AWS

```bash
cd ./terraform
export AWS_FUNCTION_URL=$(terraform output --json | jq -r '.aws_function_url.value')
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$AWS_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "test", "content": "test"}'
```

#### From Azure

```bash
cd ./terraform
export AZURE_FUNCTION_URL="https://$(terraform output --json | jq -r '.azure_function_host.value')/api/upload"
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$AZURE_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "test", "content": "test"}'
```

#### From Google

```bash
cd ./terraform
export GOOGLE_FUNCTION_URL=$(terraform output --json | jq -r '.google_function_url.value')
export API_KEY=$(terraform output --json | jq -r '.api_key.value')
curl -H "X-API-Key: $API_KEY" "$GOOGLE_FUNCTION_URL" -H "Content-Type: application/json" -d '{"filename": "test", "content": "test"}'
```

### Teardown

```bash
terraform destroy --auto-approve
```

## References

- These example functions are based on content from SANS Institute [SEC510: Public Cloud Security: AWS, Azure, and GCP](https://www.sans.org/cyber-security-courses/public-cloud-security-aws-azure-gcp/). SEC510 provides cloud security practitioners, analysts, and researchers with the nuances of multi-cloud security. Students will obtain an in-depth understanding of the inner workings of the most popular public cloud providers. Please to learn more, please visit [here](https://www.sans.org/cyber-security-courses/public-cloud-security-aws-azure-gcp/), review the syllabus, and click the **Course Demo** button for a free ~1 hour module.

- Some of the code for these functions were adapted by the [Serverless Prey project](), a collection of cloud functions that, once launched to a cloud environment and invoked, establish a TCP reverse shell, enabling the user to introspect the underlying container.
