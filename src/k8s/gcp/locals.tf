locals {
  network_addresses = {
    subnet_public_cidr_block     = "10.70.1.0/24"
    subnet_private_cidr_block    = "10.70.2.0/24"
    subnet_private_services_cidr = "10.70.3.0/24"
    subnet_private_pod_cidr      = "10.70.4.0/24"
  }

  gke = {
    cluster_name = var.tag_owner
  }

  deployment_id = random_id.deployment.hex

  services = [
    "iam.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "iap.googleapis.com",
    "container.googleapis.com",
  ]

  roles = [
    "cloudkms.admin",
    "cloudkms.cryptoKeyDecrypter",
    "cloudkms.cryptoKeyEncrypter",
    "compute.admin",
    "iam.roleAdmin",
    "iam.serviceAccountAdmin",
    "iam.serviceAccountUser",
    "resourcemanager.projectIamAdmin",
    "iam.securityAdmin",
    "iam.serviceAccountKeyAdmin",
    "iam.workloadIdentityPoolAdmin",
    "secretmanager.admin",
    "servicenetworking.networksAdmin",
    "serviceusage.serviceUsageAdmin",
    "storage.admin",
    "logging.admin",
  ]
}

resource "random_id" "deployment" {
  byte_length = 4
}
