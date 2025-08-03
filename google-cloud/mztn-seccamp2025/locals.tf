# Local variables for mztn-seccamp2025

locals {
  # Project configuration
  project_id        = "mztn-seccamp2025"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/infra"

  # Warren configuration
  warren_image_sha256 = "sha256:b359990b7ec99221eb484823728e9aae0e86191551a2f1ac8f8a1a3d9dd40c3c"
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
