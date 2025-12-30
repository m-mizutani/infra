# Firestore database for Warren

resource "google_firestore_database" "warren_database" {
  project     = local.project_id
  name        = "warren-v1"
  location_id = local.region
  type        = "FIRESTORE_NATIVE"

  # Prevent destruction
  lifecycle {
    prevent_destroy = true
  }
}

# Firestore database for Hecatoncheires

resource "google_firestore_database" "hecatoncheires_database" {
  project     = local.project_id
  name        = "hecatoncheires-v0"
  location_id = local.region
  type        = "FIRESTORE_NATIVE"

  # Prevent destruction
  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Collections that need embedding indexes
  embedding_collections = ["alerts", "tickets", "lists"]
}

# Embedding indexes (with __name__ field for each collection)
resource "google_firestore_index" "embedding" {
  for_each = toset(local.embedding_collections)

  project    = local.project_id
  database   = google_firestore_database.warren_database.name
  collection = each.value

  fields {
    field_path = "__name__"
    order      = "ASCENDING"
  }

  fields {
    field_path = "Embedding"
    vector_config {
      dimension = 256
      flat {}
    }
  }
}

# Embedding indexes with CreatedAt (for each collection)
resource "google_firestore_index" "embedding_created_at" {
  for_each = toset(local.embedding_collections)

  project    = local.project_id
  database   = google_firestore_database.warren_database.name
  collection = each.value

  fields {
    field_path = "CreatedAt"
    order      = "DESCENDING"
  }

  fields {
    field_path = "__name__"
    order      = "ASCENDING"
  }

  fields {
    field_path = "Embedding"
    vector_config {
      dimension = 256
      flat {}
    }
  }
}

# Status + CreatedAt index for tickets collection only
resource "google_firestore_index" "tickets_status_created_at" {
  project    = local.project_id
  database   = google_firestore_database.warren_database.name
  collection = "tickets"

  fields {
    field_path = "Status"
    order      = "ASCENDING"
  }

  fields {
    field_path = "CreatedAt"
    order      = "DESCENDING"
  }
}
