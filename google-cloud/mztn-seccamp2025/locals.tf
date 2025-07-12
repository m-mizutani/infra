# Local variables for mztn-seccamp2025

locals {
  # Project configuration
  project_id        = "mztn-seccamp2025"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/infra"

  # Warren configuration
  warren_image_sha256 = "sha256:7b8d99fecaa246bbba7e0a30dd237abf0b81ff148b49f0c9c1c24a032973e771"
  warren_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/warren@${local.warren_image_sha256}"

  # Warren secrets
  warren_secrets = [
    "WARREN_SLACK_OAUTH_TOKEN",
    "WARREN_OTX_API_KEY",
    "WARREN_URLSCAN_API_KEY",
    "WARREN_SLACK_SIGNING_SECRET",
    "WARREN_SLACK_CLIENT_SECRET",
  ]
}
