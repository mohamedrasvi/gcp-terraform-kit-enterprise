terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "" # Set via -backend-config or env
    prefix = "foundation/hipaa"
  }
}

provider "google" {
  # configured via env vars or -var
}

provider "google-beta" {
  # configured via env vars or -var
}
