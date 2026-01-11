# CLAUDE.md

このリポジトリは Google Cloud インフラを Terraform で管理している。

## プロジェクト構成

- `google-cloud/mztn-service/` - メインのプロダクション環境
- `google-cloud/mztn-seccamp2025/` - セキュリティキャンプ用環境
- `images/` - 各サービスの Dockerfile
- `.github/workflows/` - CI/CD ワークフロー

## 新規 Cloud Run サービスのデプロイ手順

### 1. Dockerfile の作成

`images/{service-name}/Dockerfile` を作成する。

```dockerfile
FROM ghcr.io/aquasecurity/trivy:latest AS trivy  # 必要な場合

FROM ghcr.io/example/base-image:tag

# 必要に応じて依存関係をコピー
COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy

ENV SERVICE_ADDR="0.0.0.0:8080"
ENV SERVICE_LOG_FORMAT="json"

EXPOSE 8080

ENTRYPOINT ["/app", "serve"]
```

### 2. ローカルでイメージをビルド＆プッシュ

```bash
# ビルド
cd images/{service-name}
docker build -t asia-northeast1-docker.pkg.dev/mztn-service/container-images/{service-name}:latest .

# Artifact Registry 認証
gcloud auth configure-docker asia-northeast1-docker.pkg.dev --quiet

# プッシュ
docker push asia-northeast1-docker.pkg.dev/mztn-service/container-images/{service-name}:latest
```

出力から SHA256 ダイジェストを取得する（例: `sha256:526eb36c...`）。

### 3. Terraform リソースの追加

#### 3.1 Service Account (`service-account.tf`)

```hcl
resource "google_service_account" "{service_name}_runner" {
  account_id   = "{service-name}-runner"
  display_name = "{Service Name} Runner Service Account"
  description  = "Service Account for {Service Name} Cloud Run service"
}
```

#### 3.2 シークレット定義（必要な場合）

`locals.tf` にシークレットリストを追加:

```hcl
  {service_name}_secrets = [
    "{SERVICE_NAME}_SECRET_1",
    "{SERVICE_NAME}_SECRET_2",
  ]
```

`secret.tf` にリソースを追加:

```hcl
resource "google_secret_manager_secret" "{service_name}_secrets" {
  for_each  = toset(local.{service_name}_secrets)
  secret_id = each.value
  replication { auto {} }
  labels = { service = "{service-name}" }
}

resource "google_secret_manager_secret_iam_member" "{service_name}_secret_access" {
  for_each  = toset(local.{service_name}_secrets)
  secret_id = google_secret_manager_secret.{service_name}_secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.{service_name}_runner.email}"
}
```

#### 3.3 データストア（必要な場合）

BigQuery の場合 (`bigquery.tf`):

```hcl
resource "google_bigquery_dataset" "{service_name}" {
  dataset_id  = "{service_name}"
  location    = local.region
  description = "Dataset for {Service Name}"
  labels      = { service = "{service-name}" }
  lifecycle { prevent_destroy = true }
}

resource "google_bigquery_dataset_iam_member" "{service_name}_data_editor" {
  dataset_id = google_bigquery_dataset.{service_name}.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.{service_name}_runner.email}"
}
```

#### 3.4 IAM 権限 (`iam.tf`)

```hcl
resource "google_project_iam_member" "{service_name}_logging_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.{service_name}_runner.email}"
}

resource "google_project_iam_member" "{service_name}_monitoring_writer" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.{service_name}_runner.email}"
}
```

#### 3.5 サービス設定 (`locals.tf`)

イメージ設定:

```hcl
  {service_name}_image_sha256 = "sha256:..."  # ステップ2で取得した値
  {service_name}_image_uri    = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/{service-name}@${local.{service_name}_image_sha256}"
```

Cloud Run サービス定義を `cloud_run_services` マップに追加:

```hcl
    {service-name} = {
      enabled         = local.{service_name}_image_sha256 != ""
      public_access   = true  # allUsers がアクセス可能にする場合
      image_uri       = local.{service_name}_image_uri
      service_account = google_service_account.{service_name}_runner.email
      cpu             = "1000m"
      memory          = "512Mi"
      max_instances   = 1
      timeout         = "300s"
      env_vars = {
        SERVICE_ADDR = "0.0.0.0:8080"
        # その他の環境変数
      }
      secrets = local.{service_name}_secrets  # シークレットがある場合
    }
```

#### 3.6 依存関係の更新 (`cloud-run.tf`)

`depends_on` に新しいリソースを追加:

```hcl
  depends_on = [
    # ... 既存のリソース ...
    google_service_account.{service_name}_runner,
    google_secret_manager_secret.{service_name}_secrets,  # シークレットがある場合
    google_bigquery_dataset.{service_name},  # BigQuery を使う場合
  ]
```

シークレット参照ロジックを更新（必要な場合）:

```hcl
secret = (
  can(google_secret_manager_secret.warren_secrets[env.value])
  ? google_secret_manager_secret.warren_secrets[env.value].secret_id
  : can(google_secret_manager_secret.hecatoncheires_secrets[env.value])
  ? google_secret_manager_secret.hecatoncheires_secrets[env.value].secret_id
  : can(google_secret_manager_secret.{service_name}_secrets[env.value])
  ? google_secret_manager_secret.{service_name}_secrets[env.value].secret_id
  : google_secret_manager_secret.other_secrets[env.value].secret_id
)
```

### 4. GitHub Actions ワークフローの作成

`.github/workflows/push-{service-name}-image.yml`:

```yaml
name: push-{service-name}-image

on:
  push:
    branches: [ main ]
    paths:
      - 'images/{service-name}/**'
      - '.github/workflows/push-{service-name}-image.yml'
      - '.github/workflows/deploy-cloud-run.yml'

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    uses: ./.github/workflows/deploy-cloud-run.yml
    with:
      service_name: {service-name}
      image_path: images/{service-name}
      project_id: mztn-service
    secrets: inherit
```

### 5. Terraform の検証とデプロイ

```bash
cd google-cloud/mztn-service
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### 6. シークレットの設定（デプロイ後）

Secret Manager にシークレット値を手動で設定:

```bash
echo -n "secret-value" | gcloud secrets versions add SECRET_NAME --data-file=-
```

## 命名規則

| リソース | パターン | 例 |
|----------|----------|-----|
| Service Account | `{service}-runner` | `octovy-runner` |
| BigQuery Dataset | `{service}` | `octovy` |
| Cloud Run Service | `{service-name}` | `octovy` |
| Image URI | `asia-northeast1-docker.pkg.dev/mztn-service/container-images/{service}@sha256:...` | |
| Workflow | `push-{service-name}-image.yml` | `push-octovy-image.yml` |

## 既存サービスの構成ファイル

- `locals.tf` - サービス設定、イメージ URI、シークレット定義
- `service-account.tf` - Service Account
- `secret.tf` - Secret Manager シークレット
- `iam.tf` - IAM 権限
- `cloud-run.tf` - Cloud Run サービス定義（共通ループ）
- `bigquery.tf` - BigQuery データセット
- `firestore.tf` - Firestore データベース
- `cloud-storage.tf` - Cloud Storage バケット
