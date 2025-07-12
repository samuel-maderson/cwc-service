FROM ubuntu:latest

RUN apt update && \
    apt install -y apache2 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/apache2 /var/log/apache2 && \
    chown -R www-data:www-data /var/run/apache2 /var/log/apache2

COPY <<EOF /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>CWC Vehicle Catalog API</title>
</head>
<body>
    <h1>Welcome to CWC Vehicle Catalog API</h1>
    <p>Service is running successfully!</p>
    <p>This is the vehicle catalog service.</p>
</body>
</html>
EOF

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]