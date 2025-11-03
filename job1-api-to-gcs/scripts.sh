
PROJECT_ID="my-map-315516"
SA_NAME="amc-job1-sa"

# tạo service account
gcloud iam service-accounts create ${SA_NAME} \
  --display-name "AMC Cloud Run Job 1 SA" \
  --project ${PROJECT_ID}

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
GCS_BUCKET="my-private-amc-1352" # Tên GCS Bucket từ Phase 1

# Gán quyền ghi vào GCS Bucket
gcloud storage buckets add-iam-policy-binding gs://${GCS_BUCKET} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.objectCreator"

REGION="asia-southeast1"
REPO_NAME="amc-data-jobs"
IMAGE_NAME="job1-api-to-gcs"
TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"

# tạo Artifact Registry để lưu trữ Docker image
gcloud artifacts repositories create ${REPO_NAME} \
  --repository-format=docker \
  --location=${REGION} \
  --description="Docker repository for AMC data pipeline jobs"

#  build lại image và đẩy lên Artifact Registry
gcloud builds submit --tag ${TAG} .

# tạo job trên Cloud Run
gcloud run jobs create amc-job-1 \
  --image ${TAG} \
  --region ${REGION} \
  --service-account ${SA_EMAIL} \
  --set-env-vars GCS_BUCKET_NAME=${GCS_BUCKET},MOCK_API_URL=${MOCK_URL} \
  --tasks 1 \
  --max-retries 1 \
  --cpu 1 \
  --memory 512Mi \
  --task-timeout=3600s

EXECUTION_TIME=$(date +%Y%m%d%H)
gcloud run jobs execute amc-job-1 \
  --region ${REGION} \
  --update-env-vars EXECUTION_TIME=${EXECUTION_TIME} \
  --wait https://mockapi.io/projects/68e293198e14f4523dab47a7




# Khi cần build lại image và đẩy lên Artifact Registry
 gcloud builds submit --tag ${TAG} .  
 gcloud run jobs update amc-job-1 --image ${TAG} --region ${REGION}
 gcloud run jobs execute amc-job-1 --region ${REGION}
