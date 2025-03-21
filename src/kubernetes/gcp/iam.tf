resource "google_service_account" "gke_node" {
  account_id   = "${local.gke.cluster_name}-gke-node"
  display_name = "GKE node service account"
}

resource "google_project_iam_member" "gke_node" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.gke_node.member
}

resource "google_service_account" "nymeria" {
  account_id   = "nymeria"
  display_name = "GKE Nymeria pod service account"
}

resource "google_service_account_key" "nymeria" {
  service_account_id = google_service_account.nymeria.id
}
