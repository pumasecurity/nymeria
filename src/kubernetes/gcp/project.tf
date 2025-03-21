resource "google_project_service" "this" {
  for_each = toset(local.services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_project_iam_member" "this" {
  for_each = toset(local.roles)
  project  = var.project_id
  role     = "roles/${each.key}"
  member   = "user:${data.google_client_openid_userinfo.this.email}"
}
