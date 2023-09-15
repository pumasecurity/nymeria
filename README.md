# Puma Security Cross-Cloud Workload Identity Federation

![](https://pumasecurity.github.io/nymeria/img/nymeria.png)

Welcome to Puma Security's Workload Identity Federation repository. Nymeria's goal is to help cloud identity and security teams to eliminate long-lived credentials from their cloud estate. The Cloud Infrastructure as Code (IaC) configuration in this repository includes the following resources:

* Azure Service Principal Client Id / Secret for authenticating to an Azure AD Tenant from the *Long Lived Credentials* GitHub Action.

* Azure Service Principal Federated Identity configuration for authenticating to an Azure AD Tenant using a GitHub Action's built-in OpenID Connect (OIDC) JWT.

* Azure Virtual Machine for authenticating to the AWS S3 API and Google Cloud Storage (GCS) API.

* AWS IAM User Access Keys for authenticating to the AWS S3 API from the Azure Virtual Machine using a long-lived credential.

* AWS Identity Provider configuration for authenticating to the AWS S3 API using the Azure Virtual Machine's built-in OpenID Connect JWT.

* Google Cloud Service Account Key for authenticating to the GCS API from the Azure Virtual Machine using a long-lived credential.

* Google Cloud Workload Identity Pool for authenticating to the GCS API using the Azure Virtual Machine's built-in OpenID Connect JWT.

## Documentation

Documentation, including step by step instructions for deploying the workshop and inspecting the resource configuration, can be found in the [Nymeria GitHub Pages](https://pumasecurity.github.io/nymeria/).

## Learning More

### Featured At

#### RSA Conference 2023

[![Destroying Long-Lived Cloud Credentials with Workload Identity Federation - Eric Johnson](https://pumasecurity.github.io/nymeria/img/destroying-long-lived-credentials-workload-identity-federation.png)](https://youtu.be/Loj4eOIu-zo)

[Presentation Slides](https://pumasecurity.github.io/nymeria/assets/2023_USA23_CSCO-M05_01_Destroying_Long-Lived_Cloud_Credentials_with_Workload_Identity_Federation.pdf)

## Source Code

* [Long-Lived Credential GitHub Action](./.github/workflows/long-lived-credentials.yaml)
* [Federated Identity GitHub Action](./.github/workflows/federated-identity.yaml)
* [Terraform Configuration](./src/)

## Contributors

[Eric Johnson](https://github.com/ejohn20) - Principal Security Engineer, Puma Security

[Brandon Evans](https://github.com/BrandonE) - Certified Instructor and Course Author, SANS Institute
