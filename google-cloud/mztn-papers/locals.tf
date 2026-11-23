# Local variables for mztn-papers

locals {
  # Project configuration
  project_id        = "mztn-papers"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/infra"

  # Cloud Build 2nd gen GitHub connection, created once in the console
  # (see README.md). Terraform links the repositories under it.
  cloudbuild_connection = "projects/${local.project_id}/locations/${local.region}/connections/github"

  # Image built from m-mizutani/papers release tags
  papers_image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.container_images.repository_id}/papers"

  # Release tags of m-mizutani/papers that are built and deployed
  papers_release_tag = "^v[0-9]+\\.[0-9]+\\.[0-9]+$"

  # Firestore Enterprise database used by papers
  firestore_database_id = "papers"
}
