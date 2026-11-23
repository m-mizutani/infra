# Artifact Registry publishes its notifications to a topic named "gcr" in
# the same project. The name is fixed by Artifact Registry.
resource "google_pubsub_topic" "artifact_registry" {
  name = "gcr"

  depends_on = [google_project_service.required_apis]
}
