terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source = "hashicorp/google"
      # 7.x for Firestore Enterprise (database_edition)
      version = "~> 7.0"
    }
  }

  backend "gcs" {
    bucket = "mztn-papers-terraform"
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}
