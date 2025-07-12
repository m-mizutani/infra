# Outputs for mztn-seccamp2025

output "workload_identity_provider" {
  description = "The full name of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "github_actions_service_account_email" {
  description = "Email of the GitHub Actions service account"
  value       = google_service_account.github_actions.email
}

output "warren_service_account_email" {
  description = "Email of the Warren service account"
  value       = google_service_account.warren_runner.email
}

output "warren_cloud_run_url" {
  description = "URL of the Warren Cloud Run service"
  value       = length(google_cloud_run_v2_service.warren) > 0 ? google_cloud_run_v2_service.warren[0].uri : null
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository for container images"
  value       = google_artifact_registry_repository.container_images.name
}

output "firestore_database_name" {
  description = "Name of the Firestore database"
  value       = google_firestore_database.warren_database.name
}

output "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.warren_bucket.name
}