# Image attachments of papers
resource "google_storage_bucket" "attachments" {
  name     = "mztn-papers-attachments"
  location = local.region

  lifecycle {
    prevent_destroy = true
  }

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

# Workspace configuration, one prefix per release (deploy/cloudbuild.yaml).
# Each Cloud Run revision mounts the prefix of its own release, so a
# revision always starts with the configuration it was released with.
resource "google_storage_bucket" "config" {
  name     = "mztn-papers-config"
  location = local.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}

# Cloud Deploy release sources and render artifacts
resource "google_storage_bucket" "deploy" {
  name     = "mztn-papers-deploy"
  location = local.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}
