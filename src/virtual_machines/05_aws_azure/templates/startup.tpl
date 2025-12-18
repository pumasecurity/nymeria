#!/bin/bash
sudo yum install -y jq unzip

# install azure cli
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo dnf install azure-cli -y

# create bash alias file
mkdir -p /home/ssm-user
chown -R ssm-user:ssm-user /home/ssm-user
cat >/home/ssm-user/.bash_aliases <<EOL
jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$$1"
}
EOL

# azure environment data
mkdir -p /home/ssm-user/.azure
chown -R ssm-user:ssm-user /home/ssm-user/.azure
cat >/home/ssm-user/.azure/get-resources.sh <<EOL
export AZURE_STORAGE_ACCOUNT=${azurerm_storage_account_name}
export AZURE_MANAGED_IDENTITY_CLIENT_ID=${azure_managed_identity_client_id}
export AZURE_TENANT_ID=${azure_tenant_id}
EOL
