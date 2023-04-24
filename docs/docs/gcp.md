# Google Cloud Workload Identity Federation

## Long Lived Credentials

```
source ~/.config/gcloud/get-resources.sh
echo $GCS_BUCKET_ID
echo $$GCP_PROJECT_ID

gcloud auth activate-service-account --key-file=/home/ubuntu/.config/gcloud/cross-cloud-key.json

gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-long-lived-credential.png
ls -la ~/long-lived-credential.png
```

## Workload Identity Federation

Use the token to authenticate to Google Cloud:

```
gcloud auth login --cred-file=/home/ubuntu/.config/gcloud/cross-cloud-client-config.json

gcloud config set project $GCP_PROJECT_ID
```

Copy the object from GCS:

```
gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-workload-identity.png
ls -la ~/gcp-workload-identity.png
```
