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

  # Backstream-lycaon configuration
  backstream_lycaon_image_sha256 = "sha256:219930de2d9eae90c410ccc12d09dfc41ea2973a19a710cb717da2b80502544e"
  backstream_lycaon_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-lycaon@${local.backstream_lycaon_image_sha256}"

  # Cloud Run services configuration
  cloud_run_services = {
    warren = {
      enabled         = local.warren_image_sha256 != ""
      image_uri       = local.warren_image_uri
      service_account = google_service_account.warren_runner.email
      cpu             = "1000m"
      memory          = "512Mi"
      max_instances   = 1
      env_vars = {
        WARREN_ADDR                  = "0.0.0.0:8080"
        WARREN_LOG_FORMAT            = "json"
        WARREN_LOG_LEVEL             = "debug"
        WARREN_SLACK_CHANNEL_NAME    = "alert"
        WARREN_FIRESTORE_PROJECT_ID  = local.project_id
        WARREN_FIRESTORE_DATABASE_ID = google_firestore_database.warren_database.name
        WARREN_GEMINI_PROJECT_ID     = local.project_id
        WARREN_EMBEDDING_PROJECT_ID  = local.project_id
        WARREN_STORAGE_BUCKET        = google_storage_bucket.warren_bucket.name
        WARREN_STORAGE_PREFIX        = "v1/"
        WARREN_SLACK_CLIENT_ID       = "291144675891.8985225175856"
        WARREN_FRONTEND_URL          = "https://warren-${data.google_project.this.number}.${local.region}.run.app"
        WARREN_ENABLE_GRAPHQL        = "1"
        WARREN_LANG                  = "English"
      }
      secrets = local.warren_secrets
    }

    backstream = {
      enabled         = local.backstream_image_sha256 != ""
      image_uri       = local.backstream_image_uri
      service_account = google_service_account.backstream_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-lycaon = {
      enabled         = local.backstream_lycaon_image_sha256 != ""
      image_uri       = local.backstream_lycaon_image_uri
      service_account = google_service_account.backstream_lycaon_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }
  }
}
