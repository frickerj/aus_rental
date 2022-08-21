
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

resource "google_cloud_run_service" "default" {
  project  = var.project_id
  name     = "my-scheduled-service"
  location = var.region

  template {
    spec {
      containers {
        image = ""
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api
  ]
}

resource "google_project_service" "scheduler_api" {
  project                    = var.project_id
  service                    = "scheduler.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "run_api" {
  project                    = var.project_id
  service                    = "run.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "iam_api" {
  project                    = var.project_id
  service                    = "iam.googleapis.com"
  disable_dependent_services = true
}

resource "google_service_account" "default" {
  project      = var.project_id
  account_id   = "scheduler-sa"
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = "scheduler-sa"

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_cloud_scheduler_job" "default" {
  name             = "scheduled-cloud-run-job"
  description      = "Invoke a Cloud Run container on a schedule."
  schedule         = "* * * * *" # "0 22 * * 6"
  time_zone        = "Australia/Melbourne"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloud_run_service.default.status[0].url

    oidc_token {
      service_account_email = google_service_account.default.email
    }
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.scheduler_api
  ]
}

resource "google_service_account" "sa" {
  account_id   = "cloud-run-task-invoker"
  display_name = "Cloud Run Task Invoker"
  provider     = google-beta
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
  provider = google-beta
  project  = google_cloud_run_service.default.project
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
