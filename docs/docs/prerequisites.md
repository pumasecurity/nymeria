# Prerequisites

## Background Knowledge

The workshop is written such that those with entry level Information Technology and Information Security experience can complete the steps. Just be careful to read the instructions closely and take your time. If an instruction is unclear or you get stuck, please open a pull request in the [Nymeria GitHub repository](https://github.com/pumasecurity/nymeria){: target="_blank" rel="noopener"} to improve the documentation.

Familiarity with the following services and tools can help you better understand the concepts covered during the workshop:

- [x] Identity and Access Management (IAM) in the [Azure](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview){: target="_blank" rel="noopener"}, [AWS](https://docs.aws.amazon.com/iam/){: target="_blank" rel="noopener"}, and [Google](https://cloud.google.com/iam/docs/){: target="_blank" rel="noopener"} clouds
- [x] [OpenID Connect](https://openid.net/developers/how-connect-works/){: target="_blank" rel="noopener"}
- [x] [Linux command-line interface (CLI)](https://ubuntu.com/tutorials/command-line-for-beginners){: target="_blank" rel="noopener"}
- [x] [jq](https://jqlang.github.io/jq/){: target="_blank" rel="noopener"}
- [x] [GitHub](https://docs.github.com/en){: target="_blank" rel="noopener"} and [GitHub Actions](https://docs.github.com/en/actions){: target="_blank" rel="noopener"}
- [x] [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code){: target="_blank" rel="noopener"}

## Cloud Accounts

The Nymeria workshop deploys the cross-cloud identity scenario using [GitHub](https://github.com/){: target="_blank" rel="noopener"}, [Microsoft Azure](https://portal.azure.com){: target="_blank" rel="noopener"}, [Amazon Web Services](https://console.aws.amazon.com){: target="_blank" rel="noopener"}, and [Google Cloud](https://cloud.google.com){: target="_blank" rel="noopener"}. Costs for running the workshop's resource are expected to be less than $2.50 USD per day. You are responsible for any costs incurred during the workshop.

!!! danger "Cloud Providers Required"
    You must register an account with each of the following cloud providers to successfully complete the workshop.

### GitHub Personal Account

1. Use the following link to register for a free GitHub Personal Account:

    [https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account){: target="_blank" rel="noopener"}

### Azure Subscription

1. Use the following link to register for an Azure account and create a new subscription:

    [https://azure.microsoft.com/en-us/free/](https://azure.microsoft.com/en-us/free/){: target="_blank" rel="noopener"}

1. In the [Azure Portal](https://portal.azure.com/){: target="_blank" rel="noopener"} and press the **Cloud Shell** icon next to the search box.

    ![](./img/az-portal.png)

1. Run the following commands to enable the Web and Compute APIs in your subscription.

    ```bash
    az provider register --namespace Microsoft.Web
    az provider register --namespace Microsoft.Compute
    ```

1. The workshop requires you to be able to create an Azure virtual machine. After creating the new subscription, we highly recommend manually creating a new `Standard_A2_v2` virtual machine in the `eastus` location using the Azure Portal to ensure that your account is fully activated. If you are unable to create a new virtual machine, please contact Microsoft Support to increase your quota. Follow these instructions to create a new virtual machine:

    [https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu){: target="_blank" rel="noopener"}

1. After creating the new virtual machine, you can delete the new resource group from the Azure Portal.

### AWS Account

1. Use the following link to register for a new personal free tier AWS account:

    [https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html){: target="_blank" rel="noopener"}

1. The workshop requires you to create an AWS S3 bucket. To ensure you account is fully activated, we highly recommend manually creating a new S3 bucket in the `us-east-2 (Ohio)` region using the AWS Console. If you are unable to create a new S3 bucket, please contact AWS Support to increase your quota. Follow these instructions to create a new S3 bucket:

    [https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html){: target="_blank" rel="noopener"}

1. After creating the S3 bucket, you can delete the bucket from the AWS Console.

### Google Cloud Account

1. Use the following link to register for a new personal Google Cloud project:

    [https://cloud.google.com/free](https://cloud.google.com/free){: target="_blank" rel="noopener"}

1. The workshop requires you to create a Google Cloud Storage (GCS) bucket. To ensure you account is fully activated, we highly recommend manually creating a new GCS bucket in the Google Cloud Console. If you are unable to create a new GCS bucket, please contact Google Cloud Support to increase your quota. Follow these instructions to create a new GCS bucket:

    [https://cloud.google.com/storage/docs/creating-buckets](https://cloud.google.com/storage/docs/creating-buckets){: target="_blank" rel="noopener"}

1. After creating the GCS bucket, you can delete the bucket from the Google Cloud Console.

## Next Steps

With your cloud accounts, move on to the [Getting Started](getting_started.md) section.
