# Puma Security Cross-Cloud Workload Identity Federation

![](https://pumasecurity.github.io/nymeria/img/nymeria.png)

Welcome to Puma Security's Workload Identity Federation repository. Nymeria's goal is to help cloud identity and security teams to eliminate long-lived credentials from their cloud estate. The Cloud Infrastructure as Code (IaC) configuration in this repository includes the following resources:

* [Kubernetes](./src/kubernetes/README.md)

* [Cloud Functions](./src/cloud_functions/README.md)

* [Virtual Machines](./src/virtual_machines/README.md)

## Documentation

Documentation, including step by step instructions for deploying the workshops and inspecting the resource configuration, can be found in the [Nymeria GitHub Pages](https://pumasecurity.github.io/nymeria/).

## Learning More

### Featured At

#### RSA Conference 2025

#### RSA Conference 2023

The original Nymeria workshop focused on cross-cloud authentication between GitHub Actions and the Microsoft Azure cloud, then from an Azure virtual machine to both AWS S3 and Google Cloud Storage.

[![Destroying Long-Lived Cloud Credentials with Workload Identity Federation - Eric Johnson](https://pumasecurity.github.io/nymeria/img/destroying-long-lived-credentials-workload-identity-federation.png)](https://youtu.be/Loj4eOIu-zo)

[Presentation Slides](https://pumasecurity.github.io/nymeria/assets/2023_USA23_CSCO-M05_01_Destroying_Long-Lived_Cloud_Credentials_with_Workload_Identity_Federation.pdf)

## Source Code

### Kubernetes

* [Long-Lived Credential GitHub Action](./.github/workflows/long-lived-credentials.yaml)
* [Federated Identity GitHub Action](./.github/workflows/federated-identity.yaml)
* [Terraform Configuration](./src/)

### Virtual Machines

* [Long-Lived Credential GitHub Action](./.github/workflows/long-lived-credentials.yaml)
* [Federated Identity GitHub Action](./.github/workflows/federated-identity.yaml)
* [Terraform Configuration](./src/)

## Contributors

[Eric Johnson](https://github.com/ejohn20) - Principal Security Engineer, Puma Security

[Brandon Evans](https://github.com/BrandonE) - Certified Instructor and Course Author, SANS Institute
