# amc-infra-repo/main.tf

# 1. Cấu hình Provider và Backend
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket  = "my-terraform-state-1352"   
    prefix  = "infra-repo-amc/${var.env_suffix}/state" 
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# 2. Tài nguyên GCS Bucket (Raw Landing Zone)
resource "google_storage_bucket" "landing_zone" {
  name                        = var.gcs_bucket_name
  location                    = upper(var.gcp_region) # Yêu cầu chữ hoa
  force_destroy               = true
  uniform_bucket_level_access = true
}

# 3. Tài nguyên BigQuery Dataset
resource "google_bigquery_dataset" "amc_warehouse" {
  dataset_id = "amc_data_warehouse"
  location   = upper(var.gcp_region)
}