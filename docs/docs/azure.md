# Azure Identity Provider

## Azure VM

SSH to the Azure virtual machine

```bash
terraform output --json | jq -r '.ssh_private_key.value' > ~/.ssh/nymeria.pem
chmod 400 ~/.ssh/nymeria.pem
```

Read the FQDN output

```bash
AZURE_VM_FQDN=$(terraform output --json | jq -r '.azure_virtual_machine_fqdn.value')
```

SSH to the VM

```
ssh -i ~/.ssh/nymeria.pem ubuntu@$AZURE_VM_FQDN
```
