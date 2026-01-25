# Audit log sink to BigQuery in mztn-audit project
# Exports all audit logs (Admin Activity, Data Access, System Event, Policy Denied)

resource "google_logging_project_sink" "audit_logs_to_bigquery" {
  name        = "audit-logs-to-mztn-audit"
  destination = "bigquery.googleapis.com/projects/mztn-audit/datasets/google_cloud_audit"
  filter      = "logName:\"cloudaudit.googleapis.com\""

  # Use a unique writer identity (recommended for cross-project sinks)
  unique_writer_identity = true
}

# NOTE: After applying, grant BigQuery dataEditor permission to the sink's writer identity
# gcloud projects add-iam-policy-binding mztn-audit --member="serviceAccount:service-597637332213@gcp-sa-logging.iam.gserviceaccount.com" --role="roles/bigquery.dataEditor"
