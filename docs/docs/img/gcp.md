# Google Cloud Workload Identity Federation

Use the token to authenticate to Google Cloud:

```
gcloud auth login --cred-file=/home/ubuntu/gcp-azure-cross-cloud.json
```

Copy the object from GCS:

```
gsutil cp gs://cross-cloud-xb0rr25x/gcp-workload-identity.png ~/
```
