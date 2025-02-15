variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west2"
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "tag_owner" {
  description = "Owner of the resources"
  type        = string
  default     = "nymeria"
}

variable "tag_cost_center" {
  description = "Cost center for the resources"
  type        = string
  default     = "rsac"
}
