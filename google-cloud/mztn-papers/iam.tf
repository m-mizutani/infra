# IAM for the papers runner, builder and deployer service accounts

locals {
  runner_member   = "serviceAccount:${google_service_account.papers_runner.email}"
  builder_member  = "serviceAccount:${google_service_account.papers_builder.email}"
  deployer_member = "serviceAccount:${google_service_account.papers_deployer.email}"
}

# --- runner ---------------------------------------------------------------

resource "google_project_iam_member" "runner" {
  for_each = toset([
    "roles/datastore.user",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])

  project = local.project_id
  role    = each.value
  member  = local.runner_member
}

resource "google_storage_bucket_iam_member" "runner_attachments" {
  bucket = google_storage_bucket.attachments.name
  role   = "roles/storage.objectAdmin"
  member = local.runner_member
}

resource "google_storage_bucket_iam_member" "runner_config" {
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectViewer"
  member = local.runner_member
}

# --- builder (Cloud Build triggers) ---------------------------------------

resource "google_project_iam_member" "builder" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/clouddeploy.releaser",
    "roles/run.viewer",
  ])

  project = local.project_id
  role    = each.value
  member  = local.builder_member
}

resource "google_artifact_registry_repository_iam_member" "builder_writer" {
  location   = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role       = "roles/artifactregistry.writer"
  member     = local.builder_member
}

resource "google_storage_bucket_iam_member" "builder_buckets" {
  for_each = toset([
    google_storage_bucket.config.name,
    google_storage_bucket.deploy.name,
  ])

  bucket = each.value
  role   = "roles/storage.objectAdmin"
  member = local.builder_member
}

# Creating a release acts as the Cloud Deploy execution service account
resource "google_service_account_iam_member" "builder_acts_as_deployer" {
  service_account_id = google_service_account.papers_deployer.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.builder_member
}

# Pub/Sub delivers to the Pub/Sub trigger with a token of the builder
resource "google_service_account_iam_member" "pubsub_token_creator" {
  service_account_id = google_service_account.papers_builder.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-pubsub.iam.gserviceaccount.com"

  depends_on = [google_project_service.required_apis]
}

# The Cloud Build service agent stores the GitHub token of the 2nd gen
# connection in Secret Manager; it needs this before the connection is created
resource "google_project_iam_member" "cloudbuild_agent_secret_admin" {
  project = local.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"

  depends_on = [google_project_service.required_apis]
}

# --- deployer (Cloud Deploy execution) ------------------------------------

resource "google_project_iam_member" "deployer" {
  for_each = toset([
    "roles/clouddeploy.jobRunner",
    "roles/logging.logWriter",
    # Cloud Run service, including the invoker IAM check setting
    "roles/run.admin",
    # papers firestore migrate: indexes and TTL policies
    "roles/datastore.owner",
  ])

  project = local.project_id
  role    = each.value
  member  = local.deployer_member
}

resource "google_artifact_registry_repository_iam_member" "deployer_reader" {
  location   = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role       = "roles/artifactregistry.reader"
  member     = local.deployer_member
}

resource "google_storage_bucket_iam_member" "deployer_deploy_bucket" {
  bucket = google_storage_bucket.deploy.name
  role   = "roles/storage.objectAdmin"
  member = local.deployer_member
}

# Deploying the service sets papers-runner as its identity
resource "google_service_account_iam_member" "deployer_acts_as_runner" {
  service_account_id = google_service_account.papers_runner.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.deployer_member
}
