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
resource "google_pubsub_topic" "topic" {
  name = "functions2-topic"
}
resource "google_storage_bucket" "bucket" {
  name     = "${var.project}-gcf-source"  # Every bucket name must be globally unique
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "send_to_bq.zip"
  bucket = google_storage_bucket.bucket.name
  source = "send_to_bq.zip"  # Add path to the zipped function source code
}
resource "google_cloudfunctions_function" "function" {
  name        = "send_to_bq"
  description = "function to send data to interject status table"

  event_trigger {
    trigger_region = "us-central1"
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.topic.id
    retry_policy = "RETRY_POLICY_RETRY"
  }
  service_config {
    max_instance_count  = 3
    min_instance_count = 1
    available_memory    = "4Gi"
    timeout_seconds     = 60
    max_instance_request_concurrency = 80
    available_cpu = "4"
    environment_variables = {
        SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
  }
  build_config {
      runtime = "python311"
      entry_point = "send_to_bq"  # Set the entry point 
      environment_variables = {
      GCP_PROJECT = var.project_id
    }
      source {
        storage_source {
          bucket = google_storage_bucket.bucket.name
          object = google_storage_bucket_object.object.name
        }
      }
    }
}