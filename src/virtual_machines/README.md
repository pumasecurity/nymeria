# Azure Virtual Machines (Part 1)

The first workshop in the Nymeria series focuses on cross-cloud authentication between GitHub Actions and the Microsoft Azure cloud, then from an Azure virtual machine to both AWS S3 and Google Cloud Storage.

![](../../docs/docs/img/cross-cloud-resources.png)

## Getting Started

See the [Nymeria GitHub Pages](https://pumasecurity.github.io/nymeria/) for step by step instructions on deploying the **Virtual Machine** workshop.

## Resources

* Azure Service Principal Client Id / Secret for authenticating to an Azure AD Tenant from the *Long Lived Credentials* GitHub Action.

* Azure Service Principal Federated Identity configuration for authenticating to an Azure AD Tenant using a GitHub Action's built-in OpenID Connect (OIDC) JWT.

* Azure Virtual Machine for authenticating to the AWS S3 API and Google Cloud Storage (GCS) API.

* AWS IAM User Access Keys for authenticating to the AWS S3 API from the Azure Virtual Machine using a long-lived credential.

* AWS Identity Provider configuration for authenticating to the AWS S3 API using the Azure Virtual Machine's built-in OpenID Connect JWT.

* Google Cloud Service Account Key for authenticating to the GCS API from the Azure Virtual Machine using a long-lived credential.

* Google Cloud Workload Identity Pool for authenticating to the GCS API using the Azure Virtual Machine's built-in OpenID Connect JWT.
