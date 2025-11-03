# job2-gcs-to-bq/main.py
import os
import json
import functions_framework
from google.cloud import bigquery
from google.cloud import storage
from datetime import datetime

bq_client = bigquery.Client()
storage_client = storage.Client()

@functions_framework.http
def load_gcs_to_bigquery(request):
    """
    Cloud Function được gọi bởi Cloud Workflows.
    Nó đọc file JSON Array từ GCS, chuyển đổi thành List/NDJSON trong bộ nhớ,
    và thực hiện Load Job vào BigQuery.
    """
    
    # 1. Xử lý Input
    request_json = request.get_json(silent=True)
    if not request_json or 'gcs_file_uri' not in request_json:
        return 'Missing gcs_file_uri in request body.', 400

    GCS_FILE_URI = request_json['gcs_file_uri']
    
    # 2. Phân tách URI để đọc file
    try:
        uri_parts = GCS_FILE_URI.replace("gs://", "").split("/", 1)
        bucket_name = uri_parts[0]
        file_path = uri_parts[1]
    except IndexError:
        return f'Invalid GCS URI format: {GCS_FILE_URI}', 400

    # 3. ĐỌC VÀ CHUYỂN ĐỔI (JSON Array -> Python List)
    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        # Đọc toàn bộ nội dung file (JSON Array) vào bộ nhớ
        json_content = blob.download_as_bytes()
        raw_data_list = json.loads(json_content) # Chuyển từ JSON Array string sang List of Dicts
    except Exception as e:
        print(f"ERROR: Failed to read or parse file from GCS: {e}")
        return f"Failed to process GCS file: {e}", 500

    # 4. LOAD DATA VÀO BIGQUERY
    
    # BQ Destination
    PROJECT_ID = os.environ.get('GCP_PROJECT_ID')
    DATASET_ID = os.environ.get('BQ_DATASET_ID') 
    TABLE_ID = os.environ.get('BQ_TABLE_ID')
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
    
    # Cấu hình Load Job: Tự động phát hiện Schema từ List of Dicts
    job_config = bigquery.LoadJobConfig(
        autodetect=True, # Tự động phát hiện Schema (dựa trên các trường 'createdAt', 'clicks', 'name', v.v.)
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
    )
    
    # Thực hiện Load Job từ List of Dicts trong bộ nhớ
    print(f"INFO: Starting in-memory load job of {len(raw_data_list)} records into {table_ref}")
    load_job = bq_client.load_table_from_json(
        raw_data_list, 
        table_ref, 
        job_config=job_config
    )
    
    load_job.result() # Chờ Job hoàn tất
    
    print(f"SUCCESS: {len(raw_data_list)} records loaded into BigQuery.")
    
    return 'Load job successfully completed.', 200