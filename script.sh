PROJECT_ID="my-map-315516" 
REGION="asia-southeast1"
SA_EMAIL="amc-job1-sa@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud workflows deploy amc-data-pipeline \
  --source amc-workflow.yaml \
  --location ${REGION} \
  --service-account ${SA_EMAIL}



# set GCP scheduler
WORKFLOW_NAME="amc-data-pipeline"
REGION="asia-southeast1" 

# Lệnh này lấy tên đầy đủ của tài nguyên Workflow
WORKFLOW_RESOURCE_NAME=$(gcloud workflows describe ${WORKFLOW_NAME} --location ${REGION} --format 'value(name)')

# URL API để kích hoạt Execution
WORKFLOW_API_URL="https://workflowexecutions.googleapis.com/v1/${WORKFLOW_RESOURCE_NAME}:execute"

echo $WORKFLOW_API_URL