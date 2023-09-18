{
    "type": "external_account",
    "token_url": "https://sts.googleapis.com/v1/token",
    "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
    "audience": "//iam.googleapis.com/${identity_pool_provider_name}",
    "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
    "requested_token_type": "urn:ietf:params:oauth:token-type:access_token",
    "scope": "https://www.googleapis.com/auth/cloud-platform",
    "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${service_account_email}:generateAccessToken"
}
