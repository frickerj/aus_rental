
# Specify the GCP Provider
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.google_credentials
}

# Create a GCS Bucket
resource "google_storage_bucket" "aus_rental_bucket" {
  name     = var.aus_rental_bucket
  location = var.region
}

resource "google_storage_bucket" "cloudbuild_logs_bucket" {
  name     = var.aus_rental_bucket
  location = var.region
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "aus_rental_data"
  friendly_name               = "aus_rental_data"
  description                 = "BQ for Rental data in GCS"
  location                    = var.region
  default_table_expiration_ms = 3600000
}


resource "google_bigquery_table" "aus_rental_table" {
  dataset_id = var.rental_table_id
  table_id   = "aus_rental_table"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    # use the csv's in the bucket to create the table
    source_uris = [
      "gs://${var.aus_rental_bucket}/*.csv",
    ]
  }
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}


resource "google_project_service" "gcp_resource_manager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_container_registry" "registry" {
  project  = var.project_id
  location = "ASIA"
}

resource "google_cloudbuild_trigger" "filename-trigger" {
  trigger_template {
    branch_name = "main"
    repo_name   = "aus_rental"
  }

  filename = "cloudbuild.yaml"
}
