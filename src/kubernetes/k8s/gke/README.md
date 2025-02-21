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
