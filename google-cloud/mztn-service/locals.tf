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

  # Hecatoncheires secrets
  hecatoncheires_secrets = [
    "HECATONCHEIRES_SLACK_CLIENT_SECRET",
    "HECATONCHEIRES_SLACK_BOT_TOKEN",
    "HECATONCHEIRES_SLACK_SIGNING_SECRET",
  ]

  # Backstream configuration
  backstream_image_sha256 = "sha256:f6de5a1b792b54349941608904d2a2be46f7c3c4c90ca14c836f904b08e41ff4"
  backstream_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream@${local.backstream_image_sha256}"

  # Backstream-lycaon configuration
  backstream_lycaon_image_sha256 = "sha256:219930de2d9eae90c410ccc12d09dfc41ea2973a19a710cb717da2b80502544e"
  backstream_lycaon_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-lycaon@${local.backstream_lycaon_image_sha256}"

  # Backstream-tamamo configuration
  backstream_tamamo_image_sha256 = "sha256:6f0622b80aa405df05bbf35b8a209bc5b97fbd5a77adb762140866d815bb7781"
  backstream_tamamo_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-tamamo@${local.backstream_tamamo_image_sha256}"

  # Backstream-warren configuration
  backstream_warren_image_sha256 = "sha256:af3ff5115f2006a7e0eb34d09bd21351c798e1afd98a7eb07ab593e5ce184136"
  backstream_warren_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-warren@${local.backstream_warren_image_sha256}"

  # Backstream-shepherd configuration
  backstream_shepherd_image_uri = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-shepherd:latest"

  # Backstream-hecatoncheires configuration
  backstream_hecatoncheires_image_tag = "5b03dc7bb49b3b3af2459a1157775a542f14278f"
  backstream_hecatoncheires_image_uri = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-hecatoncheires:${local.backstream_hecatoncheires_image_tag}"

  # Backstream-octovy configuration
  backstream_octovy_image_sha256 = "sha256:1e55ba1c0794b224d1f823c3a763699262185f321460d7501f3fac20d3749534"
  backstream_octovy_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/backstream-octovy@${local.backstream_octovy_image_sha256}"

  # Hecatoncheires configuration
  hecatoncheires_image_sha256 = "sha256:c8035dd77b226c29aa3ec76051e6bc02d2fa759dc61ec50c227bd161ce249bc1"
  hecatoncheires_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/hecatoncheires@${local.hecatoncheires_image_sha256}"

  # Cloud Run services configuration
  cloud_run_services = {
    warren = {
      enabled         = local.warren_image_sha256 != ""
      public_access   = true
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
      public_access   = true
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
      public_access   = true
      image_uri       = local.backstream_lycaon_image_uri
      service_account = google_service_account.backstream_lycaon_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-tamamo = {
      enabled         = local.backstream_tamamo_image_sha256 != ""
      public_access   = true
      image_uri       = local.backstream_tamamo_image_uri
      service_account = google_service_account.backstream_tamamo_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-warren = {
      enabled         = local.backstream_warren_image_sha256 != ""
      public_access   = true
      image_uri       = local.backstream_warren_image_uri
      service_account = google_service_account.backstream_warren_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-shepherd = {
      enabled         = true
      public_access   = true
      image_uri       = local.backstream_shepherd_image_uri
      service_account = google_service_account.backstream_shepherd_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-hecatoncheires = {
      enabled         = local.backstream_hecatoncheires_image_tag != ""
      public_access   = true
      image_uri       = local.backstream_hecatoncheires_image_uri
      service_account = google_service_account.backstream_hecatoncheires_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    backstream-octovy = {
      enabled         = local.backstream_octovy_image_sha256 != ""
      public_access   = true
      image_uri       = local.backstream_octovy_image_uri
      service_account = google_service_account.backstream_octovy_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "900s" # 15 minutes
      env_vars        = {}
      secrets         = []
    }

    hecatoncheires = {
      enabled         = local.hecatoncheires_image_sha256 != ""
      public_access   = true
      image_uri       = local.hecatoncheires_image_uri
      service_account = google_service_account.hecatoncheires_runner.email
      cpu             = "1000m"
      memory          = "128Mi"
      max_instances   = 1
      timeout         = "300s"
      env_vars = {
        HECATONCHEIRES_FIRESTORE_PROJECT_ID  = "mztn-service"
        HECATONCHEIRES_FIRESTORE_DATABASE_ID = google_firestore_database.hecatoncheires_database.name
        HECATONCHEIRES_SLACK_CLIENT_ID       = "291144675891.10190505582951"
        HECATONCHEIRES_BASE_URL              = "https://hecatoncheires-${data.google_project.this.number}.${local.region}.run.app"
        HECATONCHEIRES_CONFIG                = "/app/config.toml"
      }
      secrets = local.hecatoncheires_secrets
    }
  }
}
