# Firestore Enterprise database for papers. Indexes and TTL policies are
# created by `papers firestore migrate`, the predeploy hook of every release
# (deploy/skaffold.yaml), so they follow the papers version being deployed.

resource "google_firestore_database" "papers" {
  project          = local.project_id
  name             = local.firestore_database_id
  location_id      = local.region
  type             = "FIRESTORE_NATIVE"
  database_edition = "ENTERPRISE"

  # papers uses the Firestore (Native mode) API and its realtime listeners
  # (Snapshots). An Enterprise database has both off unless they are set at
  # creation, and neither can be changed afterwards.
  firestore_data_access_mode = "DATA_ACCESS_MODE_ENABLED"
  realtime_updates_mode      = "REALTIME_UPDATES_MODE_ENABLED"

  delete_protection_state = "DELETE_PROTECTION_ENABLED"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.required_apis]
}
