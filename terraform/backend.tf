terraform {
  backend "gcs" {
    bucket = "my-tfstate-bucket029348"    # GCS bucket name to store terraform tfstate
    prefix = "aus-rental"           # Update to desired prefix name. Prefix name should be unique for each Terraform project having same remote state bucket.
    }
}
