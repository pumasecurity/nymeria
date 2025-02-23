# Nymeria

The following steps and commands show how to verify a pods authentication to each cloud provider API.

## GKE Cluster Authentication

Run the following command to authenticate to the GKE clusters in your proj

```bash
gcloud container clusters get-credentials nymeria --region $TF_VAR_gcp_region --project $TF_VAR_gcp_project_id
```

List the namespaces to verify you have successfully authenticated to the cluster.

```bash
k get ns
```

The output should confirm you have created namespaces for testing connectivity using both *static credentials* and *workload identity*.

```text
static-credential             Active   11m
workload-identity             Active   11m
```

## Static Credentials

Use the following sections to verify that you can connect to each cloud provider API using the static credentials stored in a Kubernetes secret.

### AWS Cloud

Find the static credentials for AWS Cloud by running the following command:

```bash
k get secrets -n static-credential
```

You will see a secret called *aws-iam-user* that contains the static credentials to the *nymeria* IAM User in your AWS account.

```text
aws-iam-user              Opaque   2      28m
```

To see where the service account key is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n static-credential nymeria-aws
```

You will see that the deployment is mounting the IAM credentials into environment variables containing the access key and secret key.

```text
Environment:
  NYMERIA_S3_BUCKET:      nymeria-0206cb87
  AWS_ACCESS_KEY_ID:      <set to the key 'aws_secret_access_key_id' in secret 'aws-iam-user'>  Optional: false
  AWS_SECRET_ACCESS_KEY:  <set to the key 'aws_secret_access_key' in secret 'aws-iam-user'>     Optional: false
```

To verify that the IAM credentials grant access to AWS cloud resources, run the following command to exec into the nymeria-aws pod:

```bash
k exec -n static-credential -it $(k get pod -n static-credential -l app=nymeria,cloud=aws -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the aws pod, which you can use to authenticate to your project and obtain the nymeria logo from the GCS bucket.

```text
bash-4.2#
```

Verify the AWS IAM credentials properly populated into the container's environment variables.

```bash
env | grep AWS
```

The output should show the two AWS environment variables used to authenticate to the AWS account.

```json
AWS_SECRET_ACCESS_KEY=<secretkey>
AWS_ACCESS_KEY_ID=<id>
```

Use the AWS credentials to authenticate to the AWS account. The output will confirm that you have authenticating to the account as the nymeria IAM user.

```bash
aws sts get-caller-identity
```

Verify that you can list the objects in the Nymeria S3 bucket. This command will use the IAM credentials to authenticate to the S3 API.

```bash
aws s3 ls s3://$NYMERIA_S3_BUCKET
```

The results will show you the contents of the S3 bucket, including the *aws-workload-identity.png*.

```text
2025-02-22 22:40:14     156686 aws-workload-identity.png
```

### Azure Cloud

Find the static credentials for Azure Cloud by running the following command:

```bash
k get secrets -n static-credential
```

You will see a secret called *azure-service-principal* that contains the static service principal client id and client secret for the *nymeria* service principal in Entra ID.

```text
azure-service-principal   Opaque   3      18m
```

To see where the service account key is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n static-credential nymeria-azure
```

You will see that the deployment is reading the service principal credentials into a environment variables containing the client id, client secret, and tenant id.

```text
Environment:
  NYMERIA_STORAGE_ACCOUNT:  nymeria49d0fec8
  ARM_TENANT_ID:           <set to the key 'tenant_id' in secret 'azure-service-principal'>      Optional: false
  ARM_CLIENT_ID:           <set to the key 'client_id' in secret 'azure-service-principal'>      Optional: false
  ARM_CLIENT_SECRET:       <set to the key 'client_secret' in secret 'azure-service-principal'>  Optional: false
```

To verify that the service principal credentials grants access to Azure cloud resources, run the following command to exec into the nymeria-azure pod:

```bash
k exec -n static-credential -it $(k get pod -n static-credential -l app=nymeria,cloud=azure -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the azure pod, which you can use to authenticate to your tenant and obtain the nymeria logo from the Azure storage account.

```text
root [ / ]#
```

Verify the Azure service principal client id, client secret, and tenant id are properly populated into the environment variables.

```bash
env | grep ARM_
```

The output should show the three Azure environment variables used to authenticate to the service principals Entra ID tenant.

```json
ARM_CLIENT_ID=<id>
ARM_TENANT_ID=<id>
ARM_CLIENT_SECRET=<secret>
```

Use the service principal client secret to authenticate to the Entra ID tenant.

```bash
az login --service-principal --tenant ${ARM_TENANT_ID} -u ${ARM_CLIENT_ID} -p="${ARM_CLIENT_SECRET}" 
```

Verify that you can list the blobs in the Nymeria Azure storage account. This command will use the static service principal credentials to authenticate to the Azure storage API.

```bash
az storage blob list --account-name $NYMERIA_STORAGE_ACCOUNT --container-name nymeria --auth-mode login
```

The results will show you the contents of the bucket, including the *azure-workload-identity.png*.

```text
"container": "nymeria",
"content": "",
"deleted": null,
"encryptedMetadata": null,
"encryptionKeySha256": null,
"encryptionScope": null,
"hasLegalHold": null,
"hasVersionsOnly": null,
"immutabilityPolicy": {
  "expiryTime": null,
  "policyMode": null
},
"isAppendBlobSealed": null,
"isCurrentVersion": null,
"lastAccessedOn": null,
"metadata": {},
"name": "azure-workload-identity.png",
```

### Google Cloud

Find the static credentials for Google Cloud by running the following command:

```bash
k get secrets -n static-credential
```

You will see a secret called *gcp-service-account-key* that contains the static service account key for the *nymeria* service account inside of your GCP project's IAM & Admin console.

```text
gcp-service-account-key
```

To see where the service account key is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n static-credential nymeria-gcloud
```

You will see that the deployment is mounting the service account key as into a volume called *gcp-service-account-key*. The service account key will be located in the `/mnt/service-account/` directory.

```text
  Mounts:
    /mnt/service-account/ from gcp-service-account-key (rw)
Volumes:
  gcp-service-account-key:
  Type:          Secret (a volume populated by a Secret)
  SecretName:    gcp-service-account-key
  Optional:      false
```

To verify that the service account key grants access to Google cloud resources, run the following command to exec into the nymeria-gcloud pod:

```bash
k exec -n static-credential -it $(k get pod -n static-credential -l app=nymeria,cloud=gcp -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the gcloud pod, which you can use to authenticate to your project and obtain the nymeria logo from the GCS bucket.

```text
root@nymeria-gcloud-pod-id:/#
```

Verify the Nymeria service account key is properly mounted into the container.

```bash
cat /mnt/service-account/credentials.json
```

The output should show the service account key in JSON format.

```json
{
  "type": "service_account",
  "project_id": "nymeria",
  "private_key_id": "key-id",
  "private_key": "-----BEGIN PRIVATE KEY...END PRIVATE KEY----"
}
```

Use the service account key to authenticate to your GCP project.

```bash
gcloud auth activate-service-account --key-file /mnt/service-account/credentials.json
```

Verify that you can access the GCS bucket containing the Nymeria logo using the *gcloud* command. This command will use the static service account key to authenticate to the GCS API.

```bash
gcloud storage objects list gs://${NYMERIA_STORAGE_BUCKET}
```

The results will show you the contents of the bucket, including the *gcp-workload-identity.png*.

```text
content_type: image/png
crc32c_hash: dKWOQg==
creation_time: 2025-02-20T19:31:27+0000
etag: CKjo0Nz+0osDEAE=
generation: '1740079887561768'
md5_hash: 6tCS4/sEqjBS+JGclL65CA==
metageneration: 1
name: gcp-workload-identity.png
size: 159450
storage_class: STANDARD
```

## Kubernetes Workload Identity

Use the following sections to verify that you can connect to each cloud provider API using the built in workload identity credentials stored in a Kubernetes secret.

### AWS IAM Identity Provider

Start by confirming that no static credential secrets exist in the *workload-identity* namespace.

```bash
k get secrets -n workload-identity
```

Let's see how to authenticate to the AWS Cloud using the GKE service account. Run the following command to view the nymeria service account:

```bash
k describe serviceaccounts -n workload-identity nymeria
```

You will see the service account name is *nymeria*.

```text
Name:                nymeria
Namespace:           workload-identity
Labels:              app=nymeria
                     cloud=gcp
Annotations:         nymeria/cost-center: rsa
                     nymeria/owner: nymeria
```

To see how the service account is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n workload-identity nymeria-aws
```

You will see that the deployment is assigning the *nymeria* service account to all of the containers launched by the deployment:

```text
Name:                   nymeria-aws
Namespace:              workload-identity
CreationTimestamp:      Sun, 23 Feb 2025 14:03:27 -0600
Labels:                 app=nymeria
                        cloud=aws
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nymeria,cloud=aws
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=nymeria
                    cloud=aws
  Service Account:  nymeria
```

To verify that the pod's service account has access to AWS cloud resources, run the following command to exec into the *nymeria-aws* pod:

```bash
k exec -n workload-identity -it $(k get pod -n workload-identity -l app=nymeria,cloud=aws -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the workload identity aws pod, which you can use to authenticate using the pod's service account to the AWS S3 bucket and obtain the nymeria logo from the storage container.

```text
bash-4.2#
```

Verify the AWS IAM user credentials are longer in the pod's environment variables.

```bash
env | grep AWS_
```

The response confirms that only the AWS role arn and web identity token file path are stored in the environment variables. The static IAM user credentials are no longer needed.

```text
AWS_ROLE_ARN=<role-arn>
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/aws/serviceaccount/token
```

View the IAM role's identity token in the /var/run/secrets/aws/serviceaccount/token file.

```bash
cat /var/run/secrets/aws/serviceaccount/token && echo;
```

In a different Terminal on your machine, you can decode the token's payload using `jq` to view the claims. The subject uniquely identifies the service account inside the cluster and the subject / audience uniquely identify the cluster that created the token.

```bash
jq -R 'split(".") | .[1] | @base64d | fromjson' <<<"$TOKEN"'
```

```json
{
  "aud": [
    "api://AzureADTokenExchange"
  ],
  "exp": 1740261730,
  "iat": 1740258130,
  "iss": "https://container.googleapis.com/v1/projects/my-project/locations/my-region/clusters/nymeria",
  "kubernetes.io": {
    "namespace": "workload-identity",
    "node": {
      "name": "gk3-nymeria-pool-2-90a97509-kbjt",
      "uid": "eca0a527-fe6e-42a7-a423-ab8f64ca68fb"
    },
    "pod": {
      "name": "nymeria-aws-5dcbc7fc6b-hpthq",
      "uid": "3327d243-438f-4961-9627-a60a166d7623"
    },
    "serviceaccount": {
      "name": "nymeria",
      "uid": "01f131f2-0631-4b18-89ee-15b67a0d8b8e"
    }
  },
  "nbf": 1740341009,
  "sub": "system:serviceaccount:workload-identity:nymeria"
}
```

Because trust has been configured using an AWS IAM Identity provider and the IAM role's trust policy, the federated token can be used to authenticate to the AWS account instead of the long lived client secret. To view the trust relationship, you can browse to the [AWS portal](https://console.aws.amazon.com) and view the IAM Identity Providers. You will find an entry that trusts the cluster's issuer  *container.googleapis.com*. The *nymeria* IAM role also has a trust policy that grants assume role permissions through the identity provider to the token's subject.

Use the GKE pod's service account token to authenticate to the AWS account. The AWS CLI and SDKs automatically use the *AWS_ROLE_ARN* and *AWS_WEB_IDENTITY_TOKEN_FILE* environment variables to authenticate to the AWS account.

```bash
aws sts get-caller-identity
```

Verify that you can list the objects in the Nymeria S3 bucket. This command will use the IAM credentials to authenticate to the S3 API.

```bash
aws s3 ls s3://$NYMERIA_S3_BUCKET
```

The results will show you the contents of the S3 bucket, including the *aws-workload-identity.png*.

```text
2025-02-22 22:40:14     156686 aws-workload-identity.png
```

### Azure Managed Identity Federation

Start by confirming that no static credential secrets exist in the *workload-identity* namespace.

```bash
k get secrets -n workload-identity
```

Let's see how to authenticate to the Azure Cloud using the GKE service account. Run the following command to view the nymeria service account:

```bash
k describe serviceaccounts -n workload-identity nymeria
```

You will see the service account name is *nymeria*.

```text
Name:                nymeria
Namespace:           workload-identity
Labels:              app=nymeria
                     cloud=gcp
Annotations:         nymeria/cost-center: rsa
                     nymeria/owner: nymeria
```

To see how the service account is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n workload-identity nymeria-azure
```

You will see that the deployment is assigning the *nymeria* service account to all of the containers launched by the deployment:

```text
Name:                   nymeria-azure
Namespace:              workload-identity
CreationTimestamp:      Sat, 22 Feb 2025 10:42:42 -0600
Labels:                 app=nymeria
                        cloud=azure
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nymeria,cloud=azure
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=nymeria
                    cloud=azure
  Service Account:  nymeria
```

To verify that the pod's service account has access to Azure cloud resources, run the following command to exec into the *nymeria-azure* pod:

```bash
k exec -n workload-identity -it $(k get pod -n workload-identity -l app=nymeria,cloud=azure -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the workload identity azure pod, which you can use to authenticate using the pod's service account to the Azure storage account and obtain the nymeria logo from the storage container.

```text
root [ / ]#
```

Verify the Azure service principal client secret is no longer in the pod's environment variables.

```bash
env | grep ARM_
```

The response confirms that only the tenant id and client id values are stored in the environment variables. The static service principal client secret is not needed.

```text
ARM_CLIENT_ID=<id>
ARM_TENANT_ID=<id>
```

View the service principal's identity token in the /var/run/secrets/azure/serviceaccount/token file.

```bash
cat /var/run/secrets/azure/serviceaccount/token && echo;
```

In a different Terminal on your machine, you can decode the token's payload using `jq` to view the claims. The subject uniquely identifies the service account inside the cluster and the subject / audience uniquely identify the cluster that created the token.

```bash
jq -R 'split(".") | .[1] | @base64d | fromjson' <<<"$TOKEN"'
```

```json
{
  "aud": [
    "api://AzureADTokenExchange"
  ],
  "exp": 1740261730,
  "iat": 1740258130,
  "iss": "https://container.googleapis.com/v1/projects/my-project/locations/my-region/clusters/nymeria",
  "jti": "d7c222bf-2872-4002-89d9-2737c94f18fa",
  "kubernetes.io": {
    "namespace": "workload-identity",
    "node": {
      "name": "gk3-nymeria-pool-2-90a97509-kbjt",
      "uid": "eca0a527-fe6e-42a7-a423-ab8f64ca68fb"
    },
    "pod": {
      "name": "nymeria-azure-5dff96b78d-x54dk",
      "uid": "bc493859-da99-47f0-984d-da5a6353731c"
    },
    "serviceaccount": {
      "name": "nymeria",
      "uid": "01f131f2-0631-4b18-89ee-15b67a0d8b8e"
    }
  },
  "nbf": 1740258130,
  "sub": "system:serviceaccount:workload-identity:nymeria"
}
```

Because trust has been configured for the Azure managed identity, the federated token can be used to authenticate to the Azure tenant instead of the long lived client secret. To view the trust relationship, you can browse to the [Azure portal](https://portal.azure.com/) and view the *nymeria* managed identity. The federated credential settings will show an entry called *gcp-gke* that trusts the GKE cluster's issuer, audience, and subject values.

Use the GKE pod's service account token to authenticate to the Entra ID tenant.

```bash
az login --service-principal --tenant ${ARM_TENANT_ID} -u ${ARM_CLIENT_ID} --federated-token $(cat /var/run/secrets/azure/serviceaccount/token)
```

Verify that you can list the blobs in the Nymeria Azure storage account. This command will use the static service principal credentials to authenticate to the Azure storage API.

```bash
az storage blob list --account-name $NYMERIA_STORAGE_ACCOUNT --container-name nymeria --auth-mode login
```

The results will show you the contents of the bucket, including the *gcp-workload-identity.png*.

```text
"container": "nymeria",
"content": "",
"deleted": null,
"encryptedMetadata": null,
"encryptionKeySha256": null,
"encryptionScope": null,
"hasLegalHold": null,
"hasVersionsOnly": null,
"immutabilityPolicy": {
  "expiryTime": null,
  "policyMode": null
},
"isAppendBlobSealed": null,
"isCurrentVersion": null,
"lastAccessedOn": null,
"metadata": {},
"name": "azure-workload-identity.png",
```

### GKE Workload Identity Federation

Start by confirming that no static credential secrets exist in the *workload-identity* namespace.

```bash
k get secrets -n workload-identity
```

Let's see how to authenticate to the Google Cloud using a Kubernetes service account. Run the following command to view the nymeria service account:

```bash
k describe serviceaccounts -n workload-identity nymeria
```

You will see the service account name is *nymeria*.

```text
Name:                nymeria
Namespace:           workload-identity
Labels:              app=nymeria
                     cloud=gcp
Annotations:         nymeria/cost-center: rsa
                     nymeria/owner: nymeria
```

To see how the service account is used, run the following command to describe the nymeria gcloud deployment:

```bash
k describe deployment -n workload-identity nymeria-gcloud
```

You will see that the deployment is assigning the *nymeria* service account to all of the containers launched by the deployment:

```text
Name:                   nymeria-gcloud
Namespace:              workload-identity
CreationTimestamp:      Thu, 20 Feb 2025 13:08:10 -0600
Labels:                 app=nymeria
                        cloud=gcp
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=nymeria,cloud=gcp
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=nymeria
                    cloud=gcp
  Service Account:  nymeria
```

To verify that the pod's service account has access to Google cloud resources, run the following command to exec into the *nymeria-gcloud* pod:

```bash
k exec -n workload-identity -it $(k get pod -n workload-identity -l app=nymeria,cloud=gcp -o json | jq -r '.items[0].metadata.name') -- /bin/bash
```

The command creates a shell inside the workload identity gcloud pod, which you can use to authenticate using the pod's service account to your project and obtain the nymeria logo from the GCS bucket.

```text
root@nymeria-gcloud-pod-id:/#
```

Verify the Nymeria service account key is no longer mounted into the container.

```bash
cat /mnt/service-account/credentials.json
```

The response confirms that the pod does not have a static service account key.

```text
cat: /mnt/service-account/credentials.json: No such file or directory
```

View the service account's identity token in the /var/run/secrets/kubernetes.io/serviceaccount/token file.

```bash
cat /var/run/secrets/kubernetes.io/serviceaccount/token && echo;
```

In a different Terminal on your machine, you can decode the token's payload using `jq` to view the claims. The subject uniquely identifies the service account inside the cluster and the subject / audience uniquely identify the cluster that created the token.

```bash
jq -R 'split(".") | .[1] | @base64d | fromjson' <<<"$TOKEN"'
```

```json
{
  "aud": [
    "https://container.googleapis.com/v1/projects/my-project/locations/my-region/clusters/nymeria"
  ],
  "exp": 1771634149,
  "iat": 1740098149,
  "iss": "https://container.googleapis.com/v1/projects/my-project/locations/my-region/clusters/nymeria",
  "jti": "640e2e5c-e26b-45ca-852c-48cb2245dce7",
  "kubernetes.io": {
    "namespace": "workload-identity",
    "node": {
      "name": "gk3-nymeria-pool-2-28ce4262-f5td",
      "uid": "3a2f7d84-7e6d-4d58-9941-7e22d4ed6c1a"
    },
    "pod": {
      "name": "nymeria-gcloud-76c868946-w2h64",
      "uid": "eaf4279d-e70b-40f8-8001-f3dd81f0c8f3"
    },
    "serviceaccount": {
      "name": "nymeria",
      "uid": "01f131f2-0631-4b18-89ee-15b67a0d8b8e"
    },
    "warnafter": 1740101756
  },
  "nbf": 1740098149,
  "sub": "system:serviceaccount:workload-identity:nymeria"
}
```

This token is automatically read by the `gcloud` CLI and used to authenticate to the Google Cloud APIs. Run the following command to authenticate to your GCP project using the service account token and obtain the nymeria logo from the GCS bucket.

```bash
gcloud storage objects list gs://${NYMERIA_STORAGE_BUCKET}
```

The results will show you the contents of the bucket, including the *gcp-workload-identity.png*.

```text
---
bucket: nymeria-383e58d5
content_type: image/png
crc32c_hash: dKWOQg==
creation_time: 2025-02-20T19:31:27+0000
etag: CKjo0Nz+0osDEAE=
generation: '1740079887561768'
md5_hash: 6tCS4/sEqjBS+JGclL65CA==
metageneration: 1
name: gcp-workload-identity.png
size: 159450
```
