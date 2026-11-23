# Daily reset of the papers data: Cloud Scheduler runs the Cloud Run job
# papers-reset (`papers firestore reset --force-dangerous-apply`), which
# deletes every Firestore document and keeps the indexes and TTL policies.
# Images in the attachments bucket are not deleted.
#
# Terraform owns the job except its image: the postdeploy hook of Cloud
# Deploy (deploy/skaffold.yaml) switches it to the image of each release.
# Until the first release, the job holds a placeholder image and its runs
# fail without touching anything.
#
# Permissions are scoped to this job and this database:
#   papers-scheduler: run.invoker on the job only
#   papers-reset:     datastore.user on the papers database only
#   papers-deployer:  acts as papers-reset to update the job's image

resource "google_cloud_run_v2_job" "papers_reset" {
  name     = "papers-reset"
  location = local.region

  template {
    task_count = 1

    template {
      service_account = google_service_account.papers_reset.email
      max_retries     = 0
      timeout         = "1800s"

      containers {
        image   = "us-docker.pkg.dev/cloudrun/container/job:latest"
        command = ["/papers"]
        args = [
          "firestore",
          "reset",
          "--force-dangerous-apply",
          "--firestore-project-id=${local.project_id}",
          "--firestore-database-id=${local.firestore_database_id}",
        ]

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
    }
  }

  lifecycle {
    # Set by the postdeploy hook (gcloud run jobs update --image)
    ignore_changes = [
      template[0].template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [google_project_service.required_apis]
}

# Firestore access of the job, limited to the papers database
resource "google_project_iam_member" "reset_datastore_user" {
  project = local.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.papers_reset.email}"

  condition {
    title      = "papers-database-only"
    expression = "resource.name == \"projects/${local.project_id}/databases/${local.firestore_database_id}\""
  }
}

resource "google_project_iam_member" "reset_log_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.papers_reset.email}"
}

# The postdeploy hook updates the job, which runs as papers-reset
resource "google_service_account_iam_member" "deployer_acts_as_reset" {
  service_account_id = google_service_account.papers_reset.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.deployer_member
}

# Cloud Scheduler may start this job and nothing else
resource "google_cloud_run_v2_job_iam_member" "scheduler_invoker" {
  project  = local.project_id
  location = google_cloud_run_v2_job.papers_reset.location
  name     = google_cloud_run_v2_job.papers_reset.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.papers_scheduler.email}"
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
    uri         = "https://run.googleapis.com/v2/projects/${local.project_id}/locations/${local.region}/jobs/${google_cloud_run_v2_job.papers_reset.name}:run"

    oauth_token {
      service_account_email = google_service_account.papers_scheduler.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.scheduler_invoker]
}
