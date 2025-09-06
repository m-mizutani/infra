# Local variables for mztn-service

locals {
  # Project configuration
  project_id        = "mztn-service"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/infra"

  # Warren configuration
  warren_image_sha256 = "sha256:9485e767326c480de4919649d4c9c4382d6522db3e295a6704af4f5c14e59bc0"
  warren_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/warren@${local.warren_image_sha256}"

  # Warren secrets
  warren_secrets = [
    "WARREN_SLACK_OAUTH_TOKEN",
    "WARREN_OTX_API_KEY",
    "WARREN_URLSCAN_API_KEY",
    "WARREN_SLACK_SIGNING_SECRET",
    "WARREN_SLACK_CLIENT_SECRET",
    "WARREN_VT_API_KEY",
    "WARREN_IPDB_API_KEY",
  ]

  # Backstream configuration
  backstream_image_sha256 = "sha256:f6de5a1b792b54349941608904d2a2be46f7c3c4c90ca14c836f904b08e41ff4"
  backstream_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream@${local.backstream_image_sha256}"
}
