# Main Terraform configuration for mztn-develop project

resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "logging.googleapis.com",
  ])

  service = each.value

  disable_dependent_services = true
}

data "google_project" "this" {
  project_id = local.project_id
}
