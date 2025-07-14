FROM python:3.9-slim

WORKDIR /app

RUN apt update && apt install -y \
    netcat-traditional \
    default-mysql-client \
    procps \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 80

CMD ["python", "app.py"]