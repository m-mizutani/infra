# papers-reader: read-only access to every resource of this project, for
# investigating builds, releases and the running service. People use it by
# impersonation (no keys). Each role is the project-wide viewer of one service
# in use; there is no basic or organization role. Secret payloads are not
# readable.

locals {
  reader_member = "serviceAccount:${google_service_account.papers_reader.email}"

  # Principals that may impersonate papers-reader
  reader_impersonators = [
    "user:mizutani.m@gmail.com",
  ]

  # Read-only roles, also given to the claude service account (claude.tf)
  reader_roles = [
    # Observability: all logs (including Data Access audit logs), metrics,
    # traces and errors
    "roles/logging.viewer",
    "roles/logging.privateLogViewer",
    "roles/monitoring.viewer",
    "roles/cloudtrace.user",
    "roles/errorreporting.viewer",
    # Cloud Run: the papers service, its revisions and the papers-reset job
    "roles/run.viewer",
    # Cloud Build: triggers, builds and the 2nd gen GitHub connection
    "roles/cloudbuild.builds.viewer",
    "roles/cloudbuild.connectionViewer",
    # Cloud Deploy: pipeline, target, releases, rollouts and job runs
    "roles/clouddeploy.viewer",
    # Artifact Registry: repositories and images
    "roles/artifactregistry.reader",
    # Firestore: databases, documents, indexes and TTL policies
    "roles/datastore.viewer",
    # Cloud Storage: buckets and objects
    "roles/storage.bucketViewer",
    "roles/storage.objectViewer",
    # Pub/Sub topic gcr
    "roles/pubsub.viewer",
    # Cloud Scheduler job papers-reset
    "roles/cloudscheduler.viewer",
    # Secret Manager metadata only (no payloads)
    "roles/secretmanager.viewer",
    # IAM: policies, service accounts, custom roles, Workload Identity
    "roles/iam.securityReviewer",
    "roles/iam.serviceAccountViewer",
    "roles/iam.roleViewer",
    "roles/iam.workloadIdentityPoolViewer",
    # Enabled APIs
    "roles/serviceusage.serviceUsageViewer",
  ]
}

resource "google_service_account" "papers_reader" {
  account_id   = "papers-reader"
  display_name = "Papers Reader Service Account"
  description  = "Read-only access to the papers resources, used by impersonation"
}

resource "google_project_iam_member" "reader" {
  for_each = toset(local.reader_roles)

  project = local.project_id
  role    = each.value
  member  = local.reader_member
}

# Impersonation (gcloud --impersonate-service-account)
resource "google_service_account_iam_member" "reader_impersonation" {
  for_each = toset(local.reader_impersonators)

  service_account_id = google_service_account.papers_reader.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
