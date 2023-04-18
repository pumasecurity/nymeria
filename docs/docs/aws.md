# AWS Identity Provider


## AWS Workload Identity Federation

Run the following commands from the Azure VM to obtain an OpenID Connect JWT.

```bash
AZURE_JWT=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=api://nymeria-workload-identity" -H "Metadata: true" | jq -r '.access_token')
```

Validate the token is issues by the trusted Azure identity provider and the subject is the virtual machine's managed service identity.

```bash
jwt_decode "$AZURE_JWT"
```

Use the trusted OpenID Connect token to assume a role in the AWS account.

```bash
export $(aws sts assume-role-with-web-identity --region us-east-2 --role-arn "$AWS_ROLE_ARN" --role-session-name "federated-identity-azure-demo" --web-identity-token "$AZURE_JWT" --output text --query "[['AWS_ACCESS_KEY_ID',Credentials.AccessKeyId],['AWS_SECRET_ACCESS_KEY',Credentials.SecretAccessKey],['AWS_SESSION_TOKEN',Credentials.SessionToken]][*].join(\`=\`,@)")

aws sts get-caller-identity --region us-east-2

aws s3 cp --region us-east-2 s3://cross-cloud-kpgbfc1y/aws-workload-identity.png ~/aws-workload-identity.png
```
