variable "project_id" {
    description = "GCS Project ID"
    type        = string
}

variable "aus_rental_bucket" {
    description = "GCS Bucket name. Value should be unique."
    type        = string
}

variable "region" {
    description = "Google Cloud region"
    type        = string
    default     = "australia-southeast2"
}

variable "rental_table_id" {
    description = "AusRental Dataset ID"
    type        = string
}
