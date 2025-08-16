#!/bin/bash

# Update system
apt-get update -y

# Install Apache web server
apt-get install -y apache2

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

# Create a simple index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>GCP Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .header { background-color: #4285f4; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to GCP Web Server!</h1>
        </div>
        <div class="content">
            <h2>Server Information</h2>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Date:</strong> $(date)</p>
            <p><strong>Platform:</strong> Google Cloud Platform</p>
            <p><strong>Instance Zone:</strong> $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)</p>
            <p>This web server was deployed using Terraform on Google Cloud Platform.</p>
        </div>
    </div>
</body>
</html>
EOF

# Install Google Cloud SDK (already available on GCP instances)
# Authenticate using the instance service account (automatic)

# Create a script to upload Apache logs to Cloud Storage
cat > /etc/cron.daily/apache-log-gcs << 'CRON'
#!/bin/bash
DATE=$(date +%Y-%m-%d)
BUCKET_NAME="${bucket_name}"

# Upload access log to Cloud Storage
if [ -f /var/log/apache2/access.log ]; then
    gsutil cp /var/log/apache2/access.log gs://$BUCKET_NAME/$DATE/access.log
fi

# Upload error log to Cloud Storage
if [ -f /var/log/apache2/error.log ]; then
    gsutil cp /var/log/apache2/error.log gs://$BUCKET_NAME/$DATE/error.log
fi
CRON

# Make the script executable
chmod +x /etc/cron.daily/apache-log-gcs

# Set proper permissions
chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Enable and configure log rotation
cat > /etc/logrotate.d/apache2-custom << 'LOGROTATE'
/var/log/apache2/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data adm
    sharedscripts
    postrotate
        systemctl reload apache2
    endscript
}
LOGROTATE

echo "Web server setup completed successfully!"