#!/bin/bash
sudo apt install -y jq unzip

# install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp/
sudo /tmp/aws/install

# install gcloud
mkdir -p /opt/google
curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-418.0.0-linux-x86_64.tar.gz" -o "/tmp/google-cloud-cli-linux-x86_64.tar.gz"
tar -xf /tmp/google-cloud-cli-linux-x86_64.tar.gz --directory /opt/google/
/opt/google/google-cloud-sdk/install.sh --quiet --path-update true --command-completion true --rc-path /home/ubuntu/.bashrc

# jwt decode utility
# https://gist.github.com/thomasdarimont/46358bc8167fce059d83a1ebdb92b0e7
cat >/home/ubuntu/.bash_aliases <<EOL
jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$$1"
}
EOL

# aws env data
mkdir -p /home/ubuntu/.aws
chown -R ubuntu:ubuntu /home/ubuntu/.aws

cat >/home/ubuntu/.aws/config <<EOL
[profile cross-cloud]
region = ${aws_default_region}
output = json
cli_pager=

EOL

# warning: not secure do not pass secrets into init scripts IRL
cat >/home/ubuntu/.aws/credentials <<EOL
[cross-cloud]
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}

EOL

cat >/home/ubuntu/.aws/get-resources.sh <<EOL
export AWS_S3_BUCKET_ID=${aws_s3_bucket_id}
export AWS_CROSS_CLOUD_ROLE_ARN=${aws_cross_cloud_role_arn}
export AWS_DEFAULT_REGION=${aws_default_region}
EOL

# google cloud env
mkdir -p /home/ubuntu/.config/gcloud/
chown -R ubuntu:ubuntu /home/ubuntu/.config/gcloud

# warning: not secure do not pass secrets into init scripts IRL
cat >/home/ubuntu/.config/gcloud/cross-cloud-key.json <<EOL
${google_cloud_service_account_key}
EOL

cat >/home/ubuntu/.config/gcloud/cross-cloud-client-config.json <<EOL
${google_cloud_workload_identity_client_configuration}
EOL

cat >/home/ubuntu/.config/gcloud/get-resources.sh <<EOL
export GCS_BUCKET_ID=${gcs_bucket_id}
export GCP_PROEJCT_ID=${google_cloud_project_id}
EOL
