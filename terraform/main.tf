
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


resource "google_container_registry" "registry" {
  project  = var.project_id
  location = "ASIA"
}

# resource "google_cloud_run_service" "run_service" {
#   name     = "aus_rental_scraping"
#   location = var.region
#   template {
#     spec {
#       containers {
#         image = "gcr.io/google-samples/hello-app:2.0"
#       }
#     }
#   }
# }

# resource "google_service_account" "default" {
#   account_id   = "scheduler-sa"
#   description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
#   display_name = "scheduler-sa"

#   # Use an explicit depends_on clause to wait until API is enabled
#   depends_on = [
#     google_project_service.iam_api
#   ]
# }

# resource "google_cloud_scheduler_job" "default" {
#   name             = "scheduled-cloud-run-job"
#   description      = "Invoke a Cloud Run container on a schedule."
#   schedule         = "0 0 * * 6" # midnight on Saturday
#   time_zone        = "Australia/Melbourne"
#   attempt_deadline = "320s"

#   retry_config {
#     retry_count = 1
#   }

#   http_target {
#     http_method = "POST"
#     uri         = google_cloud_run_service.run_service.status[0].url

#     oidc_token {
#       service_account_email = google_service_account.default.email
#     }
#   }

#   # Use an explicit depends_on clause to wait until API is enabled
#   depends_on = [
#     google_project_service.scheduler_api
#   ]
# }
