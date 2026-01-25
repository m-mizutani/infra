output "project_id" {
  description = "The GCP project ID"
  value       = local.project_id
}

output "region" {
  description = "The GCP region"
  value       = local.region
}

output "audit_log_sink_writer_identity" {
  description = "The writer identity for the audit log sink (grant BigQuery dataEditor to this in mztn-audit)"
  value       = google_logging_project_sink.audit_logs_to_bigquery.writer_identity
}
