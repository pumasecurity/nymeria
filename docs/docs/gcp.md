# Google Cloud Workload Identity Federation

## Workload Identity Federation

1. Run the following command to set the Google Cloud project id and GCS bucket.

    ```bash
    source ~/.config/gcloud/get-resources.sh
    echo $GCS_BUCKET_ID
    echo $GCP_PROJECT_ID
    ```

1. Inspect the Google Cloud Workload Identity Federation client configuration file.

    ```bash
    cat ~/.config/gcloud/cross-cloud-client-config.json
    ```

1. Authenticate to the Google Cloud Workload Identity Pool using the client configuration file.

    ```bash
    gcloud auth login --cred-file=/home/ubuntu/.config/gcloud/cross-cloud-client-config.json

    gcloud config set project $GCP_PROJECT_ID
    ```

1. Use the temporary credential to access the GCS data.

    ```bash
    gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-workload-identity.png
    ls -la ~/gcp-workload-identity.png
    ```
