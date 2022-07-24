
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
