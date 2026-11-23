# Artifact Registry for container images. Pushes are announced on the
# Pub/Sub topic "gcr" (the fixed topic name of Artifact Registry
# notifications), which starts the deploy (cloud-build.tf).

resource "google_artifact_registry_repository" "container_images" {
  location      = local.region
  repository_id = "container-images"
  description   = "Container images repository"
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s" # 7 days
    }
  }

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 20
    }
  }

  depends_on = [google_project_service.required_apis]
}
