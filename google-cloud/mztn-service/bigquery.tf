# BigQuery dataset for Octovy

resource "google_bigquery_dataset" "octovy" {
  dataset_id  = "octovy"
  location    = local.region
  description = "Dataset for Octovy security scan results"

  labels = {
    service = "octovy"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Octovy service account access to the dataset
resource "google_bigquery_dataset_iam_member" "octovy_data_editor" {
  dataset_id = google_bigquery_dataset.octovy.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.octovy_runner.email}"
}
