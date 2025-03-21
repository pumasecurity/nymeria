resource "google_compute_network" "nymeria" {
  name                    = local.gke.cluster_name
  description             = "Network for GKE cluster"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [
    google_project_iam_member.this,
    google_project_service.this
  ]
}

resource "google_compute_subnetwork" "public" {
  name          = "lb-proxy"
  ip_cidr_range = local.network_addresses.subnet_public_cidr_block
  region        = var.region
  network       = google_compute_network.nymeria.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "private" {
  name                     = "${local.gke.cluster_name}-private"
  ip_cidr_range            = local.network_addresses.subnet_private_cidr_block
  network                  = google_compute_network.nymeria.id
  region                   = var.region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = local.network_addresses.subnet_private_services_cidr
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = local.network_addresses.subnet_private_pod_cidr
  }
}
