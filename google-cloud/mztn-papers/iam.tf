# IAM for the papers runner, builder and deployer service accounts

locals {
  runner_member   = "serviceAccount:${google_service_account.papers_runner.email}"
  builder_member  = "serviceAccount:${google_service_account.papers_builder.email}"
  deployer_member = "serviceAccount:${google_service_account.papers_deployer.email}"

  # IAM condition limiting a Firestore role to the papers database (and the
  # resources under it, such as its indexes)
  papers_database = "projects/${local.project_id}/databases/${local.firestore_database_id}"
  papers_database_condition = {
    title      = "papers-database-only"
    expression = "resource.name == \"${local.papers_database}\" || resource.name.startsWith(\"${local.papers_database}/\")"
  }
}

# --- runner ---------------------------------------------------------------

resource "google_project_iam_member" "runner" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])

  project = local.project_id
  role    = each.value
  member  = local.runner_member
}

# Firestore data of the papers database only
resource "google_project_iam_member" "runner_datastore" {
  project = local.project_id
  role    = "roles/datastore.user"
  member  = local.runner_member

  condition {
    title      = local.papers_database_condition.title
    expression = local.papers_database_condition.expression
  }
}

# Objects only (no IAM of the bucket or its objects)
resource "google_storage_bucket_iam_member" "runner_attachments" {
  bucket = google_storage_bucket.attachments.name
  role   = "roles/storage.objectUser"
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
    # Read-only: the Cloud Deploy config of the region, which
    # `gcloud deploy releases create` reads; releases are created only on
    # the papers pipeline (below)
    "roles/clouddeploy.viewer",
    # Read-only: the image and version of the running papers service
    # (papers-config). The service is owned by Cloud Deploy, so Terraform
    # cannot bind on it.
    "roles/run.viewer",
  ])

  project = local.project_id
  role    = each.value
  member  = local.builder_member
}

# Creating releases (and their rollouts) on the papers pipeline and target only
resource "google_clouddeploy_delivery_pipeline_iam_member" "builder_releaser" {
  project  = local.project_id
  location = google_clouddeploy_delivery_pipeline.papers.location
  name     = google_clouddeploy_delivery_pipeline.papers.name
  role     = "roles/clouddeploy.releaser"
  member   = local.builder_member
}

resource "google_clouddeploy_target_iam_member" "builder_releaser" {
  project  = local.project_id
  location = google_clouddeploy_target.prod.location
  name     = google_clouddeploy_target.prod.name
  role     = "roles/clouddeploy.releaser"
  member   = local.builder_member
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
  role   = "roles/storage.objectUser"
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
    # Required by Cloud Deploy on the execution service account
    "roles/clouddeploy.jobRunner",
    "roles/logging.logWriter",
    # Deploy the papers service and update the papers-reset job (no IAM)
    "roles/run.developer",
  ])

  project = local.project_id
  role    = each.value
  member  = local.deployer_member
}

# deploy/service.yaml disables the invoker IAM check (below). A resource of
# its own: the custom role id is known only after apply, so it cannot be a
# for_each key.
resource "google_project_iam_member" "deployer_run_invoker_check" {
  project = local.project_id
  role    = google_project_iam_custom_role.run_invoker_check.id
  member  = local.deployer_member
}

# Turning the invoker IAM check off (run.googleapis.com/invoker-iam-disabled)
# is an IAM change of the service, which run.developer does not include
resource "google_project_iam_custom_role" "run_invoker_check" {
  project     = local.project_id
  role_id     = "papersRunInvokerCheck"
  title       = "papers: Cloud Run invoker IAM check"
  description = "Read and set the IAM policy of Cloud Run services, to turn the invoker IAM check off"
  permissions = [
    "run.services.getIamPolicy",
    "run.services.setIamPolicy",
  ]
}

# papers firestore migrate: indexes and TTL policies of the papers database
# only, and no access to its documents
resource "google_project_iam_member" "deployer_datastore" {
  project = local.project_id
  role    = "roles/datastore.indexAdmin"
  member  = local.deployer_member

  condition {
    title      = local.papers_database_condition.title
    expression = local.papers_database_condition.expression
  }
}

resource "google_artifact_registry_repository_iam_member" "deployer_reader" {
  location   = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role       = "roles/artifactregistry.reader"
  member     = local.deployer_member
}

resource "google_storage_bucket_iam_member" "deployer_deploy_bucket" {
  bucket = google_storage_bucket.deploy.name
  role   = "roles/storage.objectUser"
  member = local.deployer_member
}

# Deploying the service sets papers-runner as its identity
resource "google_service_account_iam_member" "deployer_acts_as_runner" {
  service_account_id = google_service_account.papers_runner.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.deployer_member
}
