terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}
