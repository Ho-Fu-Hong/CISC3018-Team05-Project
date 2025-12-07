#!/bin/bash

# Dashboard Deployment Script

set -e
LOG_FILE="/var/log/dashboard_deploy.log"
exec > >(tee -a "$LOG_FILE")
echo "Starting dashboard deployment at $(date)"

# Create web directories
sudo mkdir -p /var/www/html/dashboard
sudo mkdir -p /var/www/html/dashboard/data
sudo mkdir -p /var/www/html/dashboard/assets

# Set permissions
sudo chown -R www-data:www-data /var/www/html/dashboard
sudo chmod -R 755 /var/www/html/dashboard

# Copy PHP scripts
sudo cp scripts/index.php /var/www/html/dashboard/
sudo cp scripts/predict.php /var/www/html/dashboard/
sudo cp scripts/visualize.php /var/www/html/dashboard/

# Validate Apache configuration
sudo apache2ctl configtest

# Restart Apache
sudo systemctl restart apache2
echo "Dashboard deployed at http://localhost/dashboard"
echo "Deployment completed at $(date)"
