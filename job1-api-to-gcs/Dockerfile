# job1-api-to-gcs/Dockerfile
FROM python:3.11-slim

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Copy dependencies và cài đặt
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY . .

# Lệnh mặc định sẽ được Cloud Run Job gọi
CMD ["python", "main.py"]