terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "mztn-seccamp2025-terraform"
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}