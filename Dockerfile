FROM python:3.9-slim

WORKDIR /app

RUN apt update && apt install -y \
    netcat-traditional \
    default-mysql-client \
    procps \
    iputils-ping \
    vim \
    curl \
    unzip \
    less \
    jq \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && rm -rf /var/lib/apt/lists/*

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 80

CMD ["python", "app.py"]