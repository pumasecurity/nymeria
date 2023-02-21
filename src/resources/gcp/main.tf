data "google_client_openid_userinfo" "this" {
}

data "google_project" "this" {
}

resource "random_string" "unique_id" {
  length  = 8
  lower   = true
  number  = true
  special = false
  upper   = false
}
