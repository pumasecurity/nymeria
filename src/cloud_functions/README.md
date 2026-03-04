# Cloud Functions

This directory contains a minimally-viable codebase for cloud functions that upload files to the all of the Big 3 cloud storage services using the Workload Identity Federation.

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

### Verify Successful Uploads

```bash
cd ./terraform
export UNIQUE_IDENTIFIER=$(terraform output --json | jq -r '.unique_identifier.value')

aws s3 cp s3://upload-to-big3-$UNIQUE_IDENTIFIER/$(aws s3api list-objects --bucket upload-to-big3-$UNIQUE_IDENTIFIER --query 'sort_by(Contents,&LastModified)[-1].Key' --output text) /tmp/aws_document.png

az storage blob download --only-show-errors --account-name uploadtobig3$UNIQUE_IDENTIFIER --container-name upload-to-big3 --name $(az storage blob list --only-show-errors --account-name uploadtobig3$UNIQUE_IDENTIFIER --container-name upload-to-big3 | jq -r 'sort_by(.properties.creationTime)[-1].name') --file /tmp/azure_document.png

gcloud storage cp $(gcloud storage ls -l gs://upload-to-big3-$UNIQUE_IDENTIFIER | grep 'gs://' | sort -k 2 | tail -1 | tr -s ' ' | cut -d" " -f4) /tmp/gcp_document.png

md5sum /tmp/aws_document.png /tmp/azure_document.png /tmp/gcp_document.png # All of the sums should match.
```

### Teardown

Make you are still in a terminal session that is authenticated to the cloud providers. Then, run one of the following:

```bash
terraform destroy --auto-approve
```

## References

- These example functions are based on content from SANS Institute [SEC510: Cloud Security Engineering and Controls](https://www.sans.org/cyber-security-courses/cloud-security-engineering-controls). SEC510 provides cloud security analysts, engineers, and researchers with practical security controls that can help organizations reduce their attack surface and prevent security incidents from becoming breaches. To learn more, please visit [here](https://www.sans.org/cyber-security-courses/cloud-security-engineering-controls), review the syllabus, and click the **Course Demo** button for a free ~1 hour module.

- Some of the code for these functions were adapted by the [Serverless Prey project](https://github.com/pumasecurity/serverless-prey), a collection of cloud functions that, once launched to a cloud environment and invoked, establish a TCP reverse shell, enabling the user to introspect the underlying container.
