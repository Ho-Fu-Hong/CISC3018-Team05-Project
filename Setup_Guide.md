```markdown
# Apache Spark Cluster with Jupyter & Dashboard

A Dockerized Apache Spark cluster setup with Jupyter Notebook integration and a web dashboard for crop data analysis.

## 📋 Prerequisites

- Docker Desktop installed and running
- Docker Compose installed
- At least 8GB RAM available
- Ports available: 8080, 8081, 8082, 8888, 8090, 7077, 4040

## 🏗️ Project Structure

```
.
├── docker/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── data/              # Spark data files
│   ├── notebooks/         # Jupyter notebooks
│   └── output/            # Spark job outputs
├── crop_dashboard/        # Web dashboard files
│   └── data/              # Dashboard data & models
└── DataPreprocessing_Analysis(ViVi)/  # Additional notebooks
```

## 🚀 Quick Start

### 1. Clone and Navigate

```bash
cd docker
```

### 2. Build and Start

```bash
# Build the Docker image
docker-compose build

# Start all services
docker-compose up -d

# Check status
docker ps
```

### 3. Access Services

- **Spark Master UI**: http://localhost:8080
- **Spark Worker 1 UI**: http://localhost:8081
- **Spark Worker 2 UI**: http://localhost:8082
- **Jupyter Notebook**: http://localhost:8888
- **Web Dashboard**: http://localhost:8090
- **Spark Application UI**: http://localhost:4040 (when jobs are running)

## 🛠️ Management Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker logs spark-master
docker logs spark-worker-1
docker logs spark-worker-2
```

### Stop Services

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Restart Services

```bash
docker-compose restart
```

### Execute Commands in Container

```bash
# Access master container
docker exec -it spark-master bash

# Run Spark job
docker exec spark-master spark-submit /opt/spark/data/your_script.py
```

## 📦 Cluster Configuration

### Spark Master
- **Container**: `spark-master`
- **Cores**: All available
- **Memory**: Default
- **Web UI Port**: 8080
- **Master Port**: 7077

### Spark Workers
- **Containers**: `spark-worker-1`, `spark-worker-2`
- **Cores per Worker**: 2
- **Memory per Worker**: 2GB
- **Web UI Ports**: 8081, 8082

## 📊 Working with Data

### Upload Data

Place your data files in:
```bash
docker/data/          # Accessible at /opt/spark/data in containers
```

### Create Notebooks

Place Jupyter notebooks in:
```bash
docker/notebooks/     # Accessible at /opt/spark/notebooks
```

### Access Outputs

Job outputs are saved to:
```bash
docker/output/        # Accessible at /opt/spark/output
```

## 🐍 Python Packages

Installed packages (see `requirements.txt`):
- PySpark
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn
- Jupyter
- And more...

### Add New Packages

1. Edit `requirements.txt`
2. Rebuild the image:
```bash
docker-compose build --no-cache
docker-compose up -d
```

## 🔧 Troubleshooting

### Containers Won't Start

```bash
# Check logs
docker-compose logs

# Remove all containers and start fresh
docker-compose down -v
docker-compose up -d
```

### Port Conflicts

If ports are in use, edit `docker-compose.yml` and change the port mappings:
```yaml
ports:
  - "NEW_PORT:8080"  # Change NEW_PORT to available port
```

### Out of Memory

Increase worker memory in `docker-compose.yml`:
```yaml
environment:
  - SPARK_WORKER_MEMORY=4g  # Increase from 2g to 4g
```

### Permission Issues

```bash
# Fix permissions on host
chmod -R 777 docker/data docker/notebooks docker/output

# Or inside container
docker exec -it spark-master bash
chmod -R 777 /opt/spark/data
```

## 📝 Example Spark Job

Create `test_spark.py` in `docker/data/`:

```python
from pyspark.sql import SparkSession

# Create Spark session
spark = SparkSession.builder \
    .appName("TestApp") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Create sample data
data = [("Alice", 34), ("Bob", 45), ("Charlie", 29)]
df = spark.createDataFrame(data, ["Name", "Age"])

# Show results
df.show()

# Stop session
spark.stop()
```

Run it:
```bash
docker exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    /opt/spark/data/test_spark.py
```

## 🌐 Dashboard Setup

The web dashboard is served via Apache from `/var/www/html`.

### Update Dashboard Data

```bash
# Data files location
crop_dashboard/data/

# Access from containers
/var/www/html/data/
```

## 🧹 Cleanup

```bash
# Stop and remove everything
docker-compose down -v

# Remove images
docker rmi docker_spark-master docker_spark-worker-1 docker_spark-worker-2

# Clean Docker system
docker system prune -a
```

## 📚 Additional Resources

- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [PySpark API Reference](https://spark.apache.org/docs/latest/api/python/)
- [Jupyter Documentation](https://jupyter.org/documentation)

## ⚙️ Advanced Configuration

### Scale Workers

```bash
# Add more workers
docker-compose up -d --scale spark-worker=3
```

### Custom Spark Configuration

Edit `docker-compose.yml` environment variables:
```yaml
environment:
  - SPARK_WORKER_CORES=4
  - SPARK_WORKER_MEMORY=4g
  - SPARK_EXECUTOR_MEMORY=2g
```

## 🆘 Support

For issues or questions:
1. Check container logs: `docker-compose logs`
2. Verify all containers are running: `docker ps`
3. Check Spark Master UI for worker connections
4. Ensure sufficient system resources

---

**Built with Apache Spark 🚀**
```

This README provides a complete setup guide with quick start instructions, troubleshooting tips, and examples. It's concise but covers all essential aspects of getting the project running! 📚
