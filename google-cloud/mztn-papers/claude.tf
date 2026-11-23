# claude: the service account Claude (AI agent) works as, by impersonation
# (no keys). It reads what papers-reader reads and may do only the few writes
# that operating the papers release needs:
#
#   - publish to the Pub/Sub topic gcr (start papers-deploy for a pushed tag)
#   - operate Cloud Deploy releases and rollouts of the papers pipeline
#     (create, retry, rollback), which runs as papers-deployer
#   - administer Firestore (databases, indexes, TTL policies and documents)
#
# It cannot change IAM, secrets, or any other Terraform-managed resource.

locals {
  claude_member = "serviceAccount:${google_service_account.claude.email}"

  # Principals that may impersonate claude
  claude_impersonators = [
    "user:mizutani.m@gmail.com",
  ]
}

resource "google_service_account" "claude" {
  account_id   = "claude"
  display_name = "Claude Service Account"
  description  = "Claude (AI agent): read access and the writes the papers release needs, used by impersonation"
}

resource "google_project_iam_member" "claude_reader" {
  for_each = toset(local.reader_roles)

  project = local.project_id
  role    = each.value
  member  = local.claude_member
}

# Start papers-deploy by hand (the message Artifact Registry sends on a push)
resource "google_pubsub_topic_iam_member" "claude_gcr_publisher" {
  topic  = google_pubsub_topic.artifact_registry.name
  role   = "roles/pubsub.publisher"
  member = local.claude_member
}

# Releases and rollouts of the papers pipeline and target only
resource "google_clouddeploy_delivery_pipeline_iam_member" "claude_operator" {
  project  = local.project_id
  location = google_clouddeploy_delivery_pipeline.papers.location
  name     = google_clouddeploy_delivery_pipeline.papers.name
  role     = "roles/clouddeploy.operator"
  member   = local.claude_member
}

resource "google_clouddeploy_target_iam_member" "claude_operator" {
  project  = local.project_id
  location = google_clouddeploy_target.prod.location
  name     = google_clouddeploy_target.prod.name
  role     = "roles/clouddeploy.operator"
  member   = local.claude_member
}

# Releases and rollouts run as the Cloud Deploy execution service account
resource "google_service_account_iam_member" "claude_acts_as_deployer" {
  service_account_id = google_service_account.papers_deployer.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.claude_member
}

# Firestore admin: databases (create, update, delete), indexes, TTL policies
# and documents
resource "google_project_iam_member" "claude_datastore_owner" {
  project = local.project_id
  role    = "roles/datastore.owner"
  member  = local.claude_member
}

# Impersonation (gcloud --impersonate-service-account)
resource "google_service_account_iam_member" "claude_impersonation" {
  for_each = toset(local.claude_impersonators)

  service_account_id = google_service_account.claude.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
