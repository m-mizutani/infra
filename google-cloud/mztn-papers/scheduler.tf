# Daily reset of the papers data: Cloud Scheduler runs the Cloud Run job
# papers-reset (`papers firestore reset --force-dangerous-apply`), which
# deletes every Firestore document and keeps the indexes and TTL policies.
# The job is created and kept on the deployed image by the postdeploy hook
# of Cloud Deploy (deploy/skaffold.yaml), so it is not managed here. Images
# in the attachments bucket are not deleted.

locals {
  papers_reset_job = "papers-reset"
}

# Starting a job execution needs run.jobs.run
resource "google_project_iam_member" "scheduler_run_invoker" {
  project = local.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.papers_scheduler.email}"
}

resource "google_cloud_scheduler_job" "papers_reset" {
  name        = "papers-reset"
  region      = local.region
  description = "Delete every document of the papers Firestore database once a day"
  schedule    = "17 4 * * *"
  time_zone   = "Asia/Tokyo"

  # A failed reset waits for the next day instead of retrying mid-day
  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/projects/${local.project_id}/locations/${local.region}/jobs/${local.papers_reset_job}:run"

    oauth_token {
      service_account_email = google_service_account.papers_scheduler.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_project_service.required_apis]
}
