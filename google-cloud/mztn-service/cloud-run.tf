# Cloud Run services using for_each loop
resource "google_cloud_run_v2_service" "services" {
  for_each = { for k, v in local.cloud_run_services : k => v if v.enabled }

  name     = each.key
  location = local.region

  template {
    service_account = each.value.service_account

    scaling {
      min_instance_count = 0
      max_instance_count = each.value.max_instances
    }

    containers {
      image = each.value.image_uri

      resources {
        limits = {
          cpu    = each.value.cpu
          memory = each.value.memory
        }
        cpu_idle          = true
        startup_cpu_boost = false
      }

      ports {
        container_port = 8080
        name           = "http1"
      }

      # Environment variables
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Secrets - only for services that have secrets
      dynamic "env" {
        for_each = each.value.secrets
        content {
          name = env.value
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.warren_secrets[env.value].secret_id
              version = "latest"
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }

  depends_on = [
    google_project_service.required_apis,
    google_service_account.warren_runner,
    google_service_account.backstream_runner,
    google_service_account.backstream_lycaon_runner,
    google_secret_manager_secret.warren_secrets,
    google_firestore_database.warren_database,
    google_storage_bucket.warren_bucket,
  ]
}

# Allow public access to Cloud Run services
resource "google_cloud_run_service_iam_member" "public_access" {
  for_each = google_cloud_run_v2_service.services

  location = each.value.location
  service  = each.value.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}