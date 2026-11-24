# Image attachments of papers, and the documents of HTML papers.
# The daily reset (scheduler.tf) deletes every attachment's metadata in
# Firestore but not the objects, and `papers firestore reset --demo` uploads
# the sample attachments again each time, so objects older than a day are no
# longer referenced. The lifecycle rules delete them after 7 days (the
# margin is for days the reset fails), and, because versioning keeps a
# deleted object as a noncurrent version, delete noncurrent versions 1 day
# after they became noncurrent.
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

  lifecycle_rule {
    condition {
      age        = 7
      with_state = "LIVE"
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 1
    }
    action {
      type = "Delete"
    }
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
