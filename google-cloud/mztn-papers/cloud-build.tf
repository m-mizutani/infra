# Cloud Build triggers of the papers release flow:
#
#   papers v* tag --(papers-build)--+
#                                   +--> Artifact Registry --(Pub/Sub "gcr")-->
#   papers main  --(papers-main)----+
#   papers-deploy --> Cloud Deploy release --> predeploy: firestore migrate --> Cloud Run
#
# papers-config creates a release with the running image when the
# deployment files (deploy/) change in this repository.

resource "google_cloudbuildv2_repository" "papers" {
  name              = "papers"
  location          = local.region
  parent_connection = local.cloudbuild_connection
  remote_uri        = "https://github.com/m-mizutani/papers.git"

  depends_on = [google_project_service.required_apis]
}

resource "google_cloudbuildv2_repository" "infra" {
  name              = "infra"
  location          = local.region
  parent_connection = local.cloudbuild_connection
  remote_uri        = "https://github.com/${local.github_repository}.git"

  depends_on = [google_project_service.required_apis]
}

locals {
  deploy_build_file = "google-cloud/mztn-papers/deploy/cloudbuild.yaml"
}

# Builds the image of a papers release tag and pushes it to Artifact Registry
resource "google_cloudbuild_trigger" "papers_build" {
  name            = "papers-build"
  location        = local.region
  description     = "Build m-mizutani/papers release tags into Artifact Registry"
  service_account = google_service_account.papers_builder.id

  repository_event_config {
    repository = google_cloudbuildv2_repository.papers.id
    push {
      tag = local.papers_release_tag
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      env  = ["DOCKER_BUILDKIT=1"]
      args = [
        "build",
        "--build-arg", "BUILD_VERSION=$TAG_NAME",
        "--tag", "${local.papers_image}:$TAG_NAME",
        ".",
      ]
    }

    # Pushing the tag publishes INSERT on the "gcr" topic
    images = ["${local.papers_image}:$TAG_NAME"]

    timeout = "1800s"

    options {
      machine_type = "E2_HIGHCPU_8"
      logging      = "CLOUD_LOGGING_ONLY"
    }
  }
}

# Builds the image of every push to main of papers (a merged pull request)
# and pushes it to Artifact Registry as main-<short commit SHA>
resource "google_cloudbuild_trigger" "papers_main" {
  name            = "papers-main"
  location        = local.region
  description     = "Build m-mizutani/papers main into Artifact Registry"
  service_account = google_service_account.papers_builder.id

  repository_event_config {
    repository = google_cloudbuildv2_repository.papers.id
    push {
      branch = local.papers_main_branch
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      env  = ["DOCKER_BUILDKIT=1"]
      args = [
        "build",
        "--build-arg", "BUILD_VERSION=main-$SHORT_SHA",
        "--tag", "${local.papers_image}:main-$SHORT_SHA",
        ".",
      ]
    }

    # Pushing the tag publishes INSERT on the "gcr" topic
    images = ["${local.papers_image}:main-$SHORT_SHA"]

    timeout = "1800s"

    options {
      machine_type = "E2_HIGHCPU_8"
      logging      = "CLOUD_LOGGING_ONLY"
    }
  }
}

# Starts a release when a release tag or a main build of papers lands in
# Artifact Registry
resource "google_cloudbuild_trigger" "papers_deploy" {
  name            = "papers-deploy"
  location        = local.region
  description     = "Release papers images pushed to Artifact Registry with Cloud Deploy"
  service_account = google_service_account.papers_builder.id

  pubsub_config {
    topic = google_pubsub_topic.artifact_registry.id
  }

  source_to_build {
    repository = google_cloudbuildv2_repository.infra.id
    ref        = "refs/heads/main"
    repo_type  = "GITHUB"
  }

  git_file_source {
    path       = local.deploy_build_file
    repository = google_cloudbuildv2_repository.infra.id
    revision   = "refs/heads/main"
    repo_type  = "GITHUB"
  }

  substitutions = {
    _ACTION = "$(body.message.data.action)"
    _TAG    = "$(body.message.data.tag)"
    _DIGEST = "$(body.message.data.digest)"
  }

  # Only new release tags and main builds of the papers image (not deletions,
  # not other images)
  filter = "_ACTION == \"INSERT\" && _TAG.matches(\"^${replace(local.papers_image, ".", "\\\\.")}:(v[0-9]+\\\\.[0-9]+\\\\.[0-9]+|main-[0-9a-f]+)$\")"
}

# Releases the running image again when the deployment files change
resource "google_cloudbuild_trigger" "papers_config" {
  name            = "papers-config"
  location        = local.region
  description     = "Release papers again when google-cloud/mztn-papers/deploy changes"
  service_account = google_service_account.papers_builder.id

  repository_event_config {
    repository = google_cloudbuildv2_repository.infra.id
    push {
      branch = "^main$"
    }
  }

  included_files = ["google-cloud/mztn-papers/deploy/**"]
  filename       = local.deploy_build_file

  substitutions = {
    _ACTION = ""
    _TAG    = ""
    _DIGEST = ""
  }
}
