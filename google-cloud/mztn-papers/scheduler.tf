# Daily reset of the papers data: Cloud Scheduler runs the Cloud Run job
# papers-reset (`papers firestore reset --force-dangerous-apply --demo`),
# which deletes every Firestore document (the indexes and TTL policies are
# kept), then creates each workspace's home and writes the sample papers.
# The sample images are uploaded to the attachments bucket again on each run;
# the job does not delete objects there, the bucket's lifecycle rules do
# (cloud-storage.tf).
#
# Terraform owns the job except its image and PAPERS_CONFIG: the postdeploy
# hook of Cloud Deploy (deploy/skaffold.yaml) switches them to the image and
# the workspace configuration (gs://mztn-papers-config/releases/<release>)
# of each release, so the job uses the same configuration as the service.
# Until the first release, the job holds a placeholder image and its runs
# fail without touching anything; without PAPERS_CONFIG, --demo fails before
# anything is deleted.
#
# Permissions are scoped to this job, this database and these buckets:
#   papers-scheduler: run.invoker on the job only
#   papers-reset:     datastore.user on the papers database only,
#                     objectUser on the attachments bucket,
#                     objectViewer on the config bucket
#   papers-deployer:  acts as papers-reset to update the job

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
          "--demo",
          "--firestore-project-id=${local.project_id}",
          "--firestore-database-id=${local.firestore_database_id}",
          "--attachment-backend=gcs",
          "--attachment-bucket=${google_storage_bucket.attachments.name}",
        ]

        # The whole config bucket; PAPERS_CONFIG, set by the postdeploy
        # hook, points at the release under /config/releases
        volume_mounts {
          name       = "config"
          mount_path = "/config"
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }

      volumes {
        name = "config"
        gcs {
          bucket    = google_storage_bucket.config.name
          read_only = true
          # The release prefixes have no directory objects
          mount_options = ["implicit-dirs"]
        }
      }
    }
  }

  lifecycle {
    # Set by the postdeploy hook (gcloud run jobs update --image
    # --update-env-vars=PAPERS_CONFIG=...)
    ignore_changes = [
      template[0].template[0].containers[0].image,
      template[0].template[0].containers[0].env,
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
    title      = local.papers_database_condition.title
    expression = local.papers_database_condition.expression
  }
}

# --demo uploads the sample images (objects only, no IAM of the bucket)
resource "google_storage_bucket_iam_member" "reset_attachments" {
  bucket = google_storage_bucket.attachments.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.papers_reset.email}"
}

# The workspace configuration --demo reads
resource "google_storage_bucket_iam_member" "reset_config" {
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.papers_reset.email}"
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
  description = "Delete every document of the papers Firestore database and write the sample papers once a day"
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
