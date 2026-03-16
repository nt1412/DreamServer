FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p /app/data

EXPOSE 8080 8081 8082 8083 8084 8085

COPY start-monitoring.sh /app/start-monitoring.sh
RUN chmod +x /app/start-monitoring.sh

CMD ["sh", "-c", "/app/start-monitoring.sh"]
