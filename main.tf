terraform {
    backend "gcs" { 
      bucket  = "tf-state-githubactions"
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
#Test bucket creation
#Test
