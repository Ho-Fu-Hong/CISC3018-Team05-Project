# 🌾 Cloud Crop Yield Prediction System

A cloud-based big data system for predicting crop yields using historical agricultural data, meteorological factors, and machine learning models.

##  Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

##  Overview

This project implements an integrated cloud-based system for crop yield prediction using Apache Spark for distributed data processing and machine learning. The system combines historical crop yield data with meteorological information to provide accurate yield forecasts through an interactive web dashboard.

##  Features

###  Core Functionality
- **Real-time Yield Prediction**: Input agricultural parameters and get instant yield predictions
- **Historical Data Analysis**: Explore 45,000+ agricultural records with interactive visualizations
- **Multi-dimensional Filtering**: Filter data by country, crop type, and time period
- **Model Comparison**: Test different machine learning algorithms (KNN, Gradient Boosting, Decision Tree)

###  Technical Features
- **Distributed Processing**: Apache Spark for scalable data processing
- **Web Dashboard**: Responsive LAMP stack interface with Chart.js visualizations
- **Automated Pipeline**: End-to-end data processing from ingestion to prediction
- **Containerized Deployment**: Docker-based environment for reproducibility

##  System Architecture

The system follows a three-layer architecture:

### 1. **Infrastructure Layer**
- Windows host with VirtualBox
- Ubuntu 24.04 LTS Virtual Machine
- Docker Engine managing 3 containers

### 2. **Big Data Processing Layer**
- Apache Spark cluster (1 master + 2 workers)
- Hadoop HDFS for distributed storage
- PySpark for data processing and ML

### 3. **Application Layer**
- LAMP stack (Linux, Apache, PHP, JSON)
- Interactive web dashboard
- RESTful prediction API

```
┌─────────────────────────────────────────┐
│         Web Dashboard (LAMP)            │
├─────────────────────────────────────────┤
│      Prediction API (PHP/Python)        │
├─────────────────────────────────────────┤
│  Machine Learning Models (PySpark)      │
├─────────────────────────────────────────┤
│    Distributed Processing (Spark)       │
├─────────────────────────────────────────┤
│     Distributed Storage (HDFS)          │
├─────────────────────────────────────────┤
│     Container Orchestration (Docker)    │
└─────────────────────────────────────────┘
```

##  Prerequisites

### Hardware Requirements
- **RAM**: Minimum 10-12 GB
- **CPU**: 4-6 cores
- **Storage**: 50 GB free space
- **OS**: Windows 10/11 with VirtualBox

### Software Requirements
- VirtualBox 7.0+
- Ubuntu 24.04 LTS
- Docker Engine 24.0+
- Docker Compose 2.20+
- Python 3.9+
- PHP 8.1+
- Apache 2.4+

##  Installation

### Step 1: Environment Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/crop-yield-prediction.git
cd crop-yield-prediction

# Create Ubuntu VM with VirtualBox
# - 4-6 CPU cores
# - 10-12 GB RAM
# - 50 GB disk space
# - Ubuntu 24.04 LTS
```

### Step 2: Install Dependencies
```bash
# On Ubuntu VM, run:
sudo apt update
sudo apt install docker.io docker-compose python3-pip php apache2
sudo systemctl start docker
sudo systemctl enable docker
```

### Step 3: Deploy with Docker Compose
```bash
# Start the Spark cluster and HDFS
docker-compose up -d

# Verify containers are running
docker ps

# Expected output:
# spark-master    Up
# spark-worker-1  Up
# spark-worker-2  Up
```

### Step 4: Deploy Web Dashboard
```bash
# Run the deployment script
chmod +x deploy_dashboard.sh
sudo ./deploy_dashboard.sh

# Or manually:
sudo cp -r crop_dashboard /var/www/html/
sudo chown -R www-data:www-data /var/www/html/crop_dashboard
sudo systemctl restart apache2
```

##  Usage

### Accessing the Dashboard
1. Open web browser
2. Navigate to: `http://your-server-ip/crop_dashboard/`
3. The dashboard should load with:
   - Prediction form on the left
   - Data visualization charts on the right

### Making Predictions
1. Fill in the prediction form:
   - Year (e.g., 2026)
   - Rainfall (mm/year)
   - Pesticides (tonnes)
   - Average Temperature (°C)
   - Select Country and Crop Type

2. Click "Get Predicted Yield"
3. View results in the prediction display

### Exploring Data
1. Use filter dropdowns to:
   - Select specific countries
   - Choose crop types
   - Change chart types

2. Interactive charts update in real-time

##  Project Structure

```
crop_yield_prediction/
│
├── crop_dashboard/                    # Web application
│   ├── index.html                     # Main dashboard page
│   ├── js/
│   │   └── dashboard.js              # Frontend logic
│   ├── php/
│   │   ├── predict_api.php           # Prediction API
│   │   └── data_api.php              # Data serving API
│   ├── assets/
│   │   └── data_all_records_new.json # Dataset
│   └── css/ (if any)
│
├── spark_jobs/                        # PySpark processing
│   ├── crop_yield_spark_etl.py       # Data pipeline
│   └── model_training.py             # ML model training
│
├── models/                            # Trained models
│   ├── best_model.pkl
│   └── preprocessor.pkl
│
├── scripts/                          # Deployment scripts
│   ├── setup_lamp.sh
│   ├── deploy_dashboard.sh
│   └── csv_to_json.py               # Data conversion
│
├── docker-compose.yml                # Container orchestration
├── Dockerfile                        # Spark container build
├── requirements.txt                  # Python dependencies
└── README.md                         # This file
```

##  API Documentation

### Prediction API
**Endpoint:** `GET /crop_dashboard/php/predict_api.php`

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| year | integer | Yes | Prediction year |
| rainfall | float | Yes | Rainfall in mm/year |
| pesticides | float | Yes | Pesticides in tonnes |
| temp | float | Yes | Average temperature in °C |
| country | string | Yes | Country name |
| crop | string | Yes | Crop type |

**Example Request:**
```bash
curl "http://localhost/crop_dashboard/php/predict_api.php?\
year=2026&\
rainfall=800&\
pesticides=50000&\
temp=20&\
country=United%20States&\
crop=Wheat"
```

**Response:**
```json
{
  "predicted_yield": 24567.89
}
```

### Data API
**Endpoint:** `GET /crop_dashboard/php/data_api.php`

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | string | Yes | Data type (only 'all_new' supported) |

**Example Request:**
```bash
curl "http://localhost/crop_dashboard/php/data_api.php?type=all_new"
```

##  Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run tests: `python -m pytest`
5. Commit changes: `git commit -m 'Add feature'`
6. Push to branch: `git push origin feature-name`
7. Open a Pull Request

### Code Standards
- Python: PEP 8 compliance
- PHP: PSR-12 compliance
- JavaScript: ES6+ with proper commenting
- Include docstrings for all functions
- Add unit tests for new features

##  Model Performance

Our tests show the following R² scores:
- **K-Nearest Neighbors (KNN)**: 0.9682
- **Gradient Boosting**: 0.9408
- **Decision Tree**: 0.9222

**Why Decision Tree was chosen for production:**
While KNN and Gradient Boosting had higher accuracy, Decision Tree was selected because:
1. **MVP Mindset**: 0.9222 accuracy is sufficient for initial deployment
2. **Resource Efficiency**: Lower memory footprint and faster inference
3. **Deployment Speed**: Simpler model enabled rapid system deployment
4. **Engineering Trade-off**: Best balance of accuracy vs. operational cost

##  Limitations

### Model Limitations
- Trained on historical data (may not predict unprecedented events)
- Limited feature set (lacks soil quality, pest outbreaks, irrigation data)
- Annual aggregation (no seasonal/daily granularity)

### System Limitations
- Batch processing (not real-time streaming)
- Single VM deployment (not multi-node cluster)
- JSON-based storage (scalability constraints)

##  Future Enhancements

Planned improvements include:
1. **Real-time Data Streaming**: Integrate weather API for live predictions
2. **Enhanced Models**: Implement ensemble methods and deep learning
3. **Mobile Application**: Native mobile app for field use
4. **Multi-language Support**: Internationalization for global users
5. **Cloud Deployment**: Migrate to AWS/Azure/GCP for scalability

##  References

1. FAOSTAT - Food and Agriculture Organization of the United Nations
2. World Bank Open Data - Climate and agricultural datasets
3. Our World in Data - Precipitation and temperature statistics
4. Hastie, T., Tibshirani, R., & Friedman, J. H. (2009). *The Elements of Statistical Learning*
5. Murphy, K. P. (2012). *Machine Learning: A Probabilistic Perspective*

##  Team

**Team 05 - University of Macau**
- FUNG HIO LAM (DC226156)
- FONG CHIN WAI (DC226545) - Full-stack Developer & Technical Writer
- HO FU HONG (DC226300)
- CHAN KA WAI (DC226165)

**Course:** CISC3018 - Cloud Computing and Big Data Systems  
**Instructor:** [Instructor Name]  
**Date:** December 2025

##  License

This project is for academic purposes as part of the University of Macau's CISC3018 course. All rights reserved by the project team members.

---

##  Troubleshooting

### Common Issues

**Issue 1: Apache not serving PHP files**
```bash
# Install PHP module for Apache
sudo apt install libapache2-mod-php
sudo a2enmod php
sudo systemctl restart apache2
```

**Issue 2: Permission denied for JSON files**
```bash
sudo chmod 644 /var/www/html/crop_dashboard/assets/*.json
sudo chown www-data:www-data /var/www/html/crop_dashboard/assets/*.json
```

**Issue 3: Spark workers not connecting**
```bash
# Check Spark master logs
docker logs spark-master

# Restart the cluster
docker-compose down
docker-compose up -d
```

**Issue 4: Python script execution error**
```bash
# Check Python path in predict_api.php
# Ensure the path is correct:
# $python_executable = '../.venv/bin/python3';
```

### Getting Help
For additional support:
1. Check the Apache error logs: `/var/log/apache2/error.log`
2. Review Docker container logs: `docker logs [container-name]`
3. Examine PHP error logs: `/var/log/apache2/php_error.log`
4. Contact the development team

---

*Last Updated: December 2025*  
*Version: 1.0.0*  
*System Status: 🟢 Operational*