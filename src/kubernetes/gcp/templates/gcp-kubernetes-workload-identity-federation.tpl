{
  "type": "external_account",
  "audience": "//iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${identity_pool_id}/providers/${provider_id}",
  "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
  "token_url": "https://sts.googleapis.com/v1/token",
  "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${service_account_email}:generateAccessToken",
  "credential_source": {
    "file" "${token_file}" 
  }
}
