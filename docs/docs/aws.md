# AWS Identity Provider

## AWS Workload Identity Federation

1. Run the following command from the Azure VM to obtain an OpenID Connect JWT.

    ```bash
    AZURE_JWT=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=api://nymeria-workload-identity" -H "Metadata: true" | jq -r '.access_token')
    ```

1. Validate the token is issued by the trusted Azure identity provider and the subject is the virtual machine's managed service identity.

    ```bash
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$AZURE_JWT"
    ```

1. Use the trusted OpenID Connect token to assume a role in the AWS account.

    ```bash
    source ~/.aws/get-resources.sh 
    echo $AWS_CROSS_CLOUD_ROLE_ARN

    export $(aws sts assume-role-with-web-identity --role-arn "$AWS_CROSS_CLOUD_ROLE_ARN" --role-session-name "nymeria-demo" --web-identity-token "$AZURE_JWT" --duration-seconds 3600 --output text --query "[['AWS_ACCESS_KEY_ID',Credentials.AccessKeyId],['AWS_SECRET_ACCESS_KEY',Credentials.SecretAccessKey],['AWS_SESSION_TOKEN',Credentials.SessionToken]][*].join(\`=\`,@)")

    aws sts get-caller-identity
    ```

1. Use the temporary credentials to access data in AWS S3.

    ```bash
    aws s3 cp s3://$AWS_S3_BUCKET_ID/aws-workload-identity.png ~/aws-workload-identity.png

    ls -la ~/aws-workload-identity.png
    ```
