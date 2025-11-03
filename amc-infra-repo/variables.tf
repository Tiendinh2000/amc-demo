# amc-infra-repo/variables.tf

variable "gcp_project_id" {
  description = "project ID của GCP"
  type        = string
}

variable "gcp_region" {
  description = "Khu vực triển khai."
  type        = string
  default     = "asia-southeast1"
}

variable "env_suffix" {
  description = "Hậu tố môi trường (dev/prod) cho tên tài nguyên."
  type        = string
}

variable "gcs_bucket_name" {
  description = "Tên GCS bucket cho dữ liệu raw."
  type        = string
}