# Long Lived Credentials

Explore Nymeria's long lived credentials for each cloud provider.

## Azure Service Principal Secret

From the GitHub Action called *Long Lived Credentials*, find the Azure tenant id, client id, and client secret values. Then, use those values to access the Azure subscription.

1. Start by running the `az group list` command. Observe you are not authenticated to the subscription.

    ```bash
    az group list
    ```

1. Set the following environment variables to the stolen service principal credentials.

    ```bash
    ARM_TENANT_ID=[STOLEN_TENANT_ID]
    ARM_CLIENT_ID=[STOLEN_CLIENT_ID]
    ARM_CLIENT_SECRET=[STOLEN_CLIENT_SECRET]

    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
    ```

1. The following commands will validate you are connected to the compromised Azure subscription:

    ```bash
    az group list
    az storage account list -g nymeria-federated-identity
    ```

## AWS Access Key

1. Find the long lived AWS credentials on the Nymeria virtual machine.

    ```bash
    ls -la ~/.aws/
    cat ~/.aws/credentials
    ```

1. Use the long lived credentials to access the data in AWS S3.

    ```bash
    export AWS_PROFILE=cross-cloud
    aws sts get-caller-identity

    source ~/.aws/get-resources.sh 
    echo $AWS_S3_BUCKET_ID
    aws s3 cp s3://$AWS_S3_BUCKET_ID/aws-workload-identity.png ~/aws-long-lived-credentials.png

    ls -la ~/aws-long-lived-credentials.png
    ```

## Google Cloud Service Account Key

1. Find the long lived Google Cloud credentials on the Nymeria virtual machine.

    ```bash
    ls -la ~/.config/gcloud/
    cat ~/.config/gcloud/cross-cloud-key.json
    ```

1. Use the long lived credentials to access the data in GCS.

    ```bash
    gcloud auth activate-service-account --key-file=/home/ubuntu/.config/gcloud/cross-cloud-key.json

    GCP_TOKEN=$(gcloud auth print-identity-token)
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $GCP_TOKEN

    source ~/.config/gcloud/get-resources.sh

    echo $GCS_BUCKET_ID

    gsutil cp gs://$GCS_BUCKET_ID/gcp-workload-identity.png ~/gcp-long-lived-credential.png

    ls -la ~/gcp-long-lived-credential.png
    ```
