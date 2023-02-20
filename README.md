# Puma Security Workload Identity Federation

Authenticating to public cloud APIs has historically been done using long-lived credentials:

* AWS IAM User Access Keys
* Azure Service Principal Client Id / Secrets
* Google Cloud Service Account JSON Web Tokens (JWT)

Unfortunately, managing long-lived credentials is a massive headache for development, operations, and security teams to manage. Countless breaches have been 

Workload Identity Federation is a cloud-native capability that enables authentication to public cloud APIs using an OpenID Connect Identity Provider's JSON Web Token (JWT).  configuration in this repository creates resources for authenticating resources cross-cloud between AWS, Azure, and Google Cloud.



[insert diagram here]
