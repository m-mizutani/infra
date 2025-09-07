# Service Account for Warren Cloud Run service

resource "google_service_account" "warren_runner" {
  account_id   = "warren-runner"
  display_name = "Warren Runner Service Account"
  description  = "Service Account for Warren Cloud Run service"
}

# Service Account for Backstream Cloud Run service

resource "google_service_account" "backstream_runner" {
  account_id   = "backstream-runner"
  display_name = "Backstream Runner Service Account"
  description  = "Service Account for Backstream Cloud Run service"
}

# Service Account for Backstream-lycaon Cloud Run service

resource "google_service_account" "backstream_lycaon_runner" {
  account_id   = "backstream-lycaon-runner"
  display_name = "Backstream-lycaon Runner Service Account"
  description  = "Service Account for Backstream-lycaon Cloud Run service"
} 