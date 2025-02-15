
resource "google_container_cluster" "nymeria" {
  name     = local.gke.cluster_name
  location = var.region

  network    = google_compute_network.nymeria.name
  subnetwork = google_compute_subnetwork.private.name

  # enable GKE autopilot (https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
  enable_autopilot = true

  # autopilot config
  cluster_autoscaling {
    auto_provisioning_defaults {
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
      service_account = google_service_account.gke_node.email
    }
  }

  # cluster config for  IP allocation for the internal vpc clusters
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_iam_member.gke_node
  ]
}
