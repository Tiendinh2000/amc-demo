# job1-api-to-gcs/main.py
import os
import json
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from google.cloud import storage
from datetime import datetime

# 1. Khai báo biến môi trường
MOCK_API_URL = os.getenv('MOCK_API_URL')
GCS_BUCKET_NAME = os.getenv('GCS_BUCKET_NAME')

storage_client = storage.Client()

# 2. Cấu hình Retry Strategy
def session_with_retries():
    """Cấu hình requests.Session với chiến lược thử lại (Retry Strategy)."""
    
    # Retry tối đa 3 lần cho các lỗi 5xx và timeout
    retry_strategy = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[500, 502, 503, 504],
        allowed_methods=["GET"],
        raise_on_status=False
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)
    return http

def process_and_upload_data(event_time_str):
    """Chỉ lấy data thô từ API với retry và đẩy lên GCS."""
    
    session = session_with_retries()
    
    # --- 1. Lấy Data từ API với Retry (Tối đa 3 lần) ---
    print(f"INFO: Attempting to call API at URL: {MOCK_API_URL}")
    try:
        response = session.get(MOCK_API_URL, timeout=10)
        response.raise_for_status()
        
        # Lấy phản hồi thô (raw JSON)
        raw_data = response.json()
    except Exception as e:
        print(f"ERROR: Failed to fetch data after all retries. {e}")
        raise e

    # --- 2. Upload Data Thô (Original JSON Array) lên GCS ---
    
    # Ghi dữ liệu thô (có thể là list hoặc object) dưới dạng JSON
    # 'indent=4' giúp format đẹp hơn, nhưng có thể bỏ nếu muốn file nhỏ nhất
    upload_data = json.dumps(raw_data, indent=4)
        
    file_name = f'raw_data/{event_time_str}/{event_time_str}_raw_batch.json'
    
    bucket = storage_client.bucket(GCS_BUCKET_NAME)
    blob = bucket.blob(file_name)
    
    blob.upload_from_string(
        upload_data,
        content_type='application/json'
    )
    print(f"SUCCESS: Uploaded {len(raw_data)} records to gs://{GCS_BUCKET_NAME}/{file_name}")


if __name__ == "__main__":
    execution_time = os.getenv('EXECUTION_TIME', datetime.now().strftime('%Y%m%d%H'))
    process_and_upload_data(execution_time)