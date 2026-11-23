# mztn-papers

Infrastructure of [papers](https://github.com/m-mizutani/papers) on the
`mztn-papers` project. Every release tag of papers is built and deployed
without any change to the papers repository.

## Release flow

```mermaid
flowchart LR
  T["m-mizutani/papers<br/>tag vX.Y.Z"] -->|"Cloud Build: papers-build"| AR["Artifact Registry<br/>container-images/papers:vX.Y.Z"]
  AR -->|"Pub/Sub topic gcr (INSERT)"| D["Cloud Build: papers-deploy<br/>deploy/cloudbuild.yaml"]
  C["m-mizutani/infra<br/>deploy/** on main"] -->|"Cloud Build: papers-config"| D
  D -->|"config to GCS, gcloud deploy releases create"| CD["Cloud Deploy: papers"]
  CD -->|"predeploy"| FS["papers firestore migrate"]
  FS --> CR["Cloud Run: papers"]
  CR -->|"postdeploy"| RJ["Cloud Run job: papers-reset<br/>image updated"]
  SC["Cloud Scheduler: papers-reset<br/>daily 04:17 JST"] -->|"run"| RJ
```

- **papers-build** (`cloud-build.tf`): a tag `vX.Y.Z` on m-mizutani/papers
  builds the image from source and pushes `papers:vX.Y.Z` to Artifact Registry.
- **papers-deploy**: Artifact Registry announces the push on the Pub/Sub
  topic `gcr` (the fixed topic name of Artifact Registry notifications). The
  trigger keeps only `INSERT` of a release tag of the papers image and runs
  `deploy/cloudbuild.yaml` from this repository's main branch. It copies
  `deploy/config` to `gs://mztn-papers-config/releases/<release>/` and creates
  a Cloud Deploy release pinned to the image digest. A release that already
  exists is skipped, since Pub/Sub delivers at least once.
- **papers-config**: a change under `deploy/` on main releases the running
  image again with the new configuration.
- **Cloud Deploy** (`cloud-deploy.tf`) runs `papers firestore migrate` as a
  predeploy hook (indexes and TTL policies), then deploys `deploy/service.yaml`.
  The Cloud Run service is owned by Cloud Deploy, not by Terraform.
- **Anonymous mode** (`deploy/service.yaml`, `PAPERS_ANONYMOUS=true`): there
  is no sign-in. A browser without a valid session cookie becomes a new
  anonymous user. The `main` workspace has no `[authz]`, so every user may
  use it.
- **Daily reset** (`scheduler.tf`): Cloud Scheduler runs the Cloud Run job
  `papers-reset` every day at 04:17 JST. The job runs
  `papers firestore reset --force-dangerous-apply`, which deletes **every
  document** in the Firestore database and keeps its indexes and TTL policies.
  Terraform owns the job except its image, which the postdeploy hook switches
  to the deployed image; until the first release it holds a placeholder image
  and its runs fail harmlessly. The job runs as `papers-reset`, which may use
  only the `papers` database (`roles/datastore.user` with an IAM condition),
  and `papers-scheduler` may start only this job (`roles/run.invoker` on the
  job). The server keeps running, so a write during the reset may survive it,
  and images in the attachments bucket are not deleted.
  Run it by hand with `gcloud run jobs execute papers-reset --region=asia-northeast1`.

Roll back with `gcloud deploy targets rollback papers-prod --delivery-pipeline=papers --region=asia-northeast1`.

## Investigating (read-only)

`papers-reader@mztn-papers.iam.gserviceaccount.com` (`reader.tf`) can read
every resource of the project: the project-wide viewer role of each service
in use, all logs (Data Access audit logs too), metrics, traces and errors. It
cannot read secret payloads. Use it by impersonation
(the principals in `reader_impersonators`):

```bash
gcloud config set auth/impersonate_service_account papers-reader@mztn-papers.iam.gserviceaccount.com
gcloud deploy rollouts list --delivery-pipeline=papers --release=<release> --region=asia-northeast1 --project=mztn-papers
gcloud logging read 'resource.type="cloud_run_revision"' --project=mztn-papers --limit=50
```

## Layout

| Path | Contents |
|---|---|
| `*.tf` | Project resources: APIs, Artifact Registry, Pub/Sub, Firestore Enterprise, buckets, service accounts, Cloud Build triggers, Cloud Deploy, Cloud Scheduler, the read-only papers-reader |
| `deploy/service.yaml` | The Cloud Run service (placeholders `PAPERS_*` are filled by `cloudbuild.yaml`) |
| `deploy/skaffold.yaml` | Render and deploy config, and the custom actions `firestore-setup` (predeploy: `papers firestore migrate`) and `reset-job` (postdeploy: the papers-reset job) |
| `deploy/cloudbuild.yaml` | Creates a release (run by papers-deploy and papers-config) |
| `deploy/config/` | Workspace configuration: `workspaces/*.toml` (+ Rego policies) and `global.toml` |

## Bootstrap (once)

1. Create the state bucket by hand (it is not managed by Terraform) and
   initialize from a local machine (the GitHub Actions service account is
   created by this configuration):

   ```bash
   gcloud storage buckets create gs://mztn-papers-terraform --project=mztn-papers --location=asia-northeast1 --uniform-bucket-level-access
   cd google-cloud/mztn-papers
   terraform init
   ```

   Commit the `.terraform.lock.hcl` that `terraform init` writes.

2. Grant the Cloud Build service agent Secret Manager access (also in
   `iam.tf`; needed before the connection can be created), then create the
   Cloud Build GitHub connection in the console: Cloud Build >
   Repositories (2nd gen) > Create host connection, region `asia-northeast1`,
   name `github`. Install the Cloud Build GitHub App on `m-mizutani/papers`
   and `m-mizutani/infra`.

   ```bash
   gcloud projects add-iam-policy-binding mztn-papers --member="serviceAccount:service-$(gcloud projects describe mztn-papers --format='value(projectNumber)')@gcp-sa-cloudbuild.iam.gserviceaccount.com" --role=roles/secretmanager.admin
   gcloud builds connections create github github --project=mztn-papers --region=asia-northeast1
   ```

3. Apply:

   ```bash
   terraform apply
   ```

4. Commit `.terraform.lock.hcl`. From then on, Terraform is applied only from
   main: pushes to main that change the Terraform files run
   `terraform-apply-mztn-papers.yml` (Workload Identity Federation as
   `github-actions@mztn-papers.iam.gserviceaccount.com`).

5. Push a release tag on m-mizutani/papers (or run the papers-build trigger
   by hand on an existing tag) for the first deploy.
