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

# Service Account for Backstream-tamamo Cloud Run service

resource "google_service_account" "backstream_tamamo_runner" {
  account_id   = "backstream-tamamo-runner"
  display_name = "Backstream-tamamo Runner Service Account"
  description  = "Service Account for Backstream-tamamo Cloud Run service"
}

# Service Account for Backstream-warren Cloud Run service

resource "google_service_account" "backstream_warren_runner" {
  account_id   = "backstream-warren-runner"
  display_name = "Backstream-warren Runner Service Account"
  description  = "Service Account for Backstream-warren Cloud Run service"
}

# Service Account for Backstream-shepherd Cloud Run service

resource "google_service_account" "backstream_shepherd_runner" {
  account_id   = "backstream-shepherd-runner"
  display_name = "Backstream-shepherd Runner Service Account"
  description  = "Service Account for Backstream-shepherd Cloud Run service"
} 