variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "eks_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.large"
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
