# Runs the papers Cloud Run service
resource "google_service_account" "papers_runner" {
  account_id   = "papers-runner"
  display_name = "Papers Runner Service Account"
  description  = "Service Account for the papers Cloud Run service"
}

# Runs the Cloud Build triggers: builds release images and creates
# Cloud Deploy releases
resource "google_service_account" "papers_builder" {
  account_id   = "papers-builder"
  display_name = "Papers Builder Service Account"
  description  = "Service Account for the papers Cloud Build triggers"
}

# Execution service account of Cloud Deploy: renders, runs the predeploy
# hook (papers firestore setup) and deploys to Cloud Run
resource "google_service_account" "papers_deployer" {
  account_id   = "papers-deployer"
  display_name = "Papers Deployer Service Account"
  description  = "Execution Service Account for the papers Cloud Deploy pipeline"
}
