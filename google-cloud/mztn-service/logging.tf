# Audit log sink to BigQuery in mztn-audit project
# Exports all audit logs (Admin Activity, Data Access, System Event, Policy Denied)

resource "google_logging_project_sink" "audit_logs_to_bigquery" {
  name        = "audit-logs-to-mztn-audit"
  destination = "bigquery.googleapis.com/projects/mztn-audit/datasets/google_cloud_audit"
  filter      = "logName:\"cloudaudit.googleapis.com\""

  # Use a unique writer identity (recommended for cross-project sinks)
  unique_writer_identity = true
}

# Grant the log sink's service account permission to write to the BigQuery dataset
resource "google_bigquery_dataset_iam_member" "audit_log_sink_writer" {
  project    = "mztn-audit"
  dataset_id = "google_cloud_audit"
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit_logs_to_bigquery.writer_identity
}
