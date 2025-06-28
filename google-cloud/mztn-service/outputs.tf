# Outputs for use in build and deployment scripts

output "project_id" {
  description = "The GCP project ID"
  value       = local.project_id
}

output "region" {
  description = "The GCP region"
  value       = local.region
}

output "artifact_registry_repository" {
  description = "The Artifact Registry repository name"
  value       = google_artifact_registry_repository.container_images.name
}

output "artifact_registry_location" {
  description = "The Artifact Registry location"
  value       = google_artifact_registry_repository.container_images.location
}

output "docker_registry_url" {
  description = "The full Docker registry URL for pushing images"
  value       = "${google_artifact_registry_repository.container_images.location}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.container_images.repository_id}"
}

output "warren_image_uri" {
  description = "The full Warren image URI"
  value       = local.warren_image_uri
} 