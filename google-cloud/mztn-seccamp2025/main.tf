# Main Terraform configuration for mztn-seccamp2025 project

# Required APIs for Workforce Identity and general operations
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "run.googleapis.com",
    "firestore.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "aiplatform.googleapis.com",
    "clouddeploy.googleapis.com",
    "cloudbuild.googleapis.com",
  ])

  service = each.value

  disable_dependent_services = true
}

data "google_project" "this" {
  project_id = local.project_id
}
