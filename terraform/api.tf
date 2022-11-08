

resource "google_project_service" "iam_api" {
  project            = var.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "cloudrun_api" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = true
}


resource "google_project_service" "cloudbuild_api" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = true
}


resource "google_project_service" "gcr_api" {
  project            = var.project_id
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = true
}


resource "google_project_service" "scheduler_api" {
  project            = var.project_id
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = true
}
