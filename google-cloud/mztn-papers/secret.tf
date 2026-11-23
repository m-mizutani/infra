# Secrets for papers. Values are added by hand:
#   echo -n "value" | gcloud secrets versions add NAME --data-file=- --project=mztn-papers

resource "google_secret_manager_secret" "papers_secrets" {
  for_each = toset(local.papers_secrets)

  secret_id = each.value

  replication {
    auto {}
  }

  labels = {
    service = "papers"
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_iam_member" "papers_secret_access" {
  for_each = toset(local.papers_secrets)

  secret_id = google_secret_manager_secret.papers_secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.papers_runner.email}"
}
