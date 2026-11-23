# papers-reader: read-only access to every resource of this project, for
# investigating builds, releases and the running service. People use it by
# impersonation (no keys). Each role is the viewer of one service in use;
# there is no basic or organization role. Object data is readable only in the
# buckets below, secret payloads and the Terraform state bucket are not.

locals {
  reader_member = "serviceAccount:${google_service_account.papers_reader.email}"

  # Principals that may impersonate papers-reader
  reader_impersonators = [
    "user:mizutani.m@gmail.com",
  ]
}

resource "google_service_account" "papers_reader" {
  account_id   = "papers-reader"
  display_name = "Papers Reader Service Account"
  description  = "Read-only access to the papers resources, used by impersonation"
}

resource "google_project_iam_member" "reader" {
  for_each = toset([
    # Cloud Run: the papers service, its revisions and the papers-reset job
    "roles/run.viewer",
    # Logs of the service, the job, Cloud Build and Cloud Deploy
    "roles/logging.viewer",
    "roles/monitoring.viewer",
    # Cloud Build: triggers, builds and the 2nd gen GitHub connection
    "roles/cloudbuild.builds.viewer",
    "roles/cloudbuild.connectionViewer",
    # Cloud Deploy: pipeline, target, releases, rollouts and job runs
    "roles/clouddeploy.viewer",
    # Pub/Sub topic gcr
    "roles/pubsub.viewer",
    # Cloud Scheduler job papers-reset
    "roles/cloudscheduler.viewer",
    # Secret Manager metadata only (no payloads)
    "roles/secretmanager.viewer",
    # Bucket metadata (objects: per bucket below)
    "roles/storage.bucketViewer",
    # IAM: policies, service accounts, custom roles, Workload Identity
    "roles/iam.securityReviewer",
    "roles/iam.serviceAccountViewer",
    "roles/iam.roleViewer",
    "roles/iam.workloadIdentityPoolViewer",
    # Enabled APIs
    "roles/serviceusage.serviceUsageViewer",
  ])

  project = local.project_id
  role    = each.value
  member  = local.reader_member
}

# Firestore: the papers database, its documents, indexes and TTL policies
resource "google_project_iam_member" "reader_datastore" {
  project = local.project_id
  role    = "roles/datastore.viewer"
  member  = local.reader_member

  condition {
    title      = local.papers_database_condition.title
    expression = local.papers_database_condition.expression
  }
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  location   = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role       = "roles/artifactregistry.reader"
  member     = local.reader_member
}

resource "google_storage_bucket_iam_member" "reader_buckets" {
  for_each = toset([
    google_storage_bucket.attachments.name,
    google_storage_bucket.config.name,
    google_storage_bucket.deploy.name,
  ])

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = local.reader_member
}

# Impersonation (gcloud --impersonate-service-account)
resource "google_service_account_iam_member" "reader_impersonation" {
  for_each = toset(local.reader_impersonators)

  service_account_id = google_service_account.papers_reader.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
