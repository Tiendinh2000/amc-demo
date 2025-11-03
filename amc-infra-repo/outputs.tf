# amc-infra-repo/outputs.tf

output "landing_bucket_id" {
  description = "Tên của GCS Bucket Landing Zone."
  value       = google_storage_bucket.landing_zone.name
}

output "bq_dataset_id" {
  description = "ID của BigQuery Dataset."
  value       = google_bigquery_dataset.amc_warehouse.dataset_id
}