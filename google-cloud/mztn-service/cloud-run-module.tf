# Reusable locals for Cloud Run services
locals {
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
      env_vars        = {}
      secrets         = []
    }
  }
}