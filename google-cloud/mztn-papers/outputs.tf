output "workload_identity_provider" {
  description = "The full name of the Workload Identity Provider"
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
}

output "project_number" {
  description = "Project number (set it as the MZTN_PAPERS_PROJECT_NUMBER repository variable)"
  value       = data.google_project.this.number
}

output "papers_url" {
  description = "URL of the papers service (Google OAuth redirect: <url>/api/auth/callback)"
  value       = "https://papers-${data.google_project.this.number}.${local.region}.run.app"
}
