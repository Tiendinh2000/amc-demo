PROJECT_ID="my-map-315516" 
REGION="asia-southeast1" 
# SỬ DỤNG LẠI SERVICE ACCOUNT CỦA JOB 1
SA_EMAIL="amc-job1-sa@${PROJECT_ID}.iam.gserviceaccount.com" 

# Lệnh triển khai
gcloud functions deploy load-gcs-to-bq \
  --runtime python311 \
  --region ${REGION} \
  --source job2-gcs-to-bq/ \
  --entry-point load_gcs_to_bigquery \
  --trigger-http \
  --allow-unauthenticated \
  --service-account ${SA_EMAIL} \
  --set-env-vars GCP_PROJECT_ID=${PROJECT_ID},BQ_DATASET_ID=amc_data_warehouse,BQ_TABLE_ID=amc_transactions \
  --timeout 300s