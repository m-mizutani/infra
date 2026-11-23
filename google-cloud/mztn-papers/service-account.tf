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
# hook (papers firestore migrate) and deploys to Cloud Run
resource "google_service_account" "papers_deployer" {
  account_id   = "papers-deployer"
  display_name = "Papers Deployer Service Account"
  description  = "Execution Service Account for the papers Cloud Deploy pipeline"
}

# Runs the papers-reset Cloud Run job (Firestore of the papers database only)
resource "google_service_account" "papers_reset" {
  account_id   = "papers-reset"
  display_name = "Papers Reset Service Account"
  description  = "Service Account for the papers-reset Cloud Run job"
}

# Identity of Cloud Scheduler when it starts the daily papers-reset job
resource "google_service_account" "papers_scheduler" {
  account_id   = "papers-scheduler"
  display_name = "Papers Scheduler Service Account"
  description  = "Service Account that Cloud Scheduler uses to run the papers-reset job"
}
