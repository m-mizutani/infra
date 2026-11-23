# Terraform state bucket for mztn-papers

resource "google_storage_bucket" "terraform_state" {
  name     = "mztn-papers-terraform"
  location = local.region

  lifecycle {
    prevent_destroy = true
  }

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
