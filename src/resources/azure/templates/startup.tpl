#!/bin/bash
sudo apt install -y jq unzip

# install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp/
sudo /tmp/aws/install

# install gcloud
mkdir -p /opt/google
curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-418.0.0-linux-x86_64.tar.gz" -o "/tmp/google/google-cloud-cli-linux-x86_64.tar.gz"
tar -xf /tmp/google-cloud-cli-linux-x86_64.tar.gz --directory /opt/google/
/opt/google/google-cloud-sdk/install.sh --quiet --path-update true --command-completion true --rc-path /home/ubuntu/.bashrc

# jwt decode utility
# https://gist.github.com/thomasdarimont/46358bc8167fce059d83a1ebdb92b0e7
cat >/home/ubuntu/.bash_aliases <<EOL
function jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}
EOL
