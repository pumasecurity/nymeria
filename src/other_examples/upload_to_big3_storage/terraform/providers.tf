terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
