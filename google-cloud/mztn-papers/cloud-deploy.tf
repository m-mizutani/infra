# Cloud Deploy: one Cloud Run target and a pipeline whose predeploy hook
# runs `papers firestore migrate` and whose postdeploy hook updates the Cloud
# Run job papers-reset to the deployed image (the custom actions in
# deploy/skaffold.yaml).
# The Cloud Run service itself is defined by deploy/service.yaml and owned
# by Cloud Deploy, not by Terraform.

resource "google_clouddeploy_target" "prod" {
  name     = "papers-prod"
  location = local.region

  run {
    location = "projects/${local.project_id}/locations/${local.region}"
  }

  execution_configs {
    usages           = ["RENDER", "DEPLOY", "PREDEPLOY", "POSTDEPLOY", "VERIFY"]
    service_account  = google_service_account.papers_deployer.email
    artifact_storage = "gs://${google_storage_bucket.deploy.name}/artifacts"
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_clouddeploy_delivery_pipeline" "papers" {
  name     = "papers"
  location = local.region

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.prod.name

      strategy {
        standard {
          verify = false
          predeploy {
            actions = ["firestore-setup"]
          }
          postdeploy {
            actions = ["reset-job"]
          }
        }
      }
    }
  }
}
