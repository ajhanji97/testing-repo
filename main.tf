terraform {
    backend "gcs" { 
      bucket  = "terraform-state-jb-cicdproject"
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
resource "google_storage_bucket" "raw" {
  project = var.project
  name = "${var.data-project}-raw"
  force_destroy = false
  uniform_bucket_level_access = true
  location = var.region
  labels = local.labels
}