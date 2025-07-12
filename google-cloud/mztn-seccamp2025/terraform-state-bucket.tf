# Terraform state bucket for mztn-seccamp2025

resource "google_storage_bucket" "terraform_state" {
  name     = "mztn-seccamp2025-terraform"
  location = local.region

  # Prevent destruction
  lifecycle {
    prevent_destroy = true
  }

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # Optional: Configure lifecycle management
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}