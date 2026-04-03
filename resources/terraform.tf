terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
  backend "gcs" {
    bucket = "" # Set via -backend-config or backend.hcl
    prefix = "resources"
  }
}

provider "google" {
  project = var.project_id
  region  = var.default_region
}

provider "google-beta" {
  project = var.project_id
  region  = var.default_region
}
