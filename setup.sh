#!/bin/bash

echo "🚀 CISC3018 Crop Yield Prediction System - Fast Setup"
echo "======================================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 0: Clean up any existing containers
echo -e "${YELLOW}🧹 Cleaning up existing containers...${NC}"
cd Docker 2>/dev/null || { echo -e "${RED}Error: Docker directory not found${NC}"; exit 1; }

docker-compose down 2>/dev/null
docker stop spark-master spark-worker-1 spark-worker-2 2>/dev/null
docker rm spark-master spark-worker-1 spark-worker-2 2>/dev/null

# Check if port 80 is in use
echo -e "${YELLOW}🔍 Checking port 80...${NC}"
if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${RED}⚠️  Port 80 is occupied!${NC}"
    echo -e "${YELLOW}Finding what's using port 80...${NC}"
    sudo lsof -i :80
    echo ""
    read -p "Do you want to stop the service using port 80? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PID=$(sudo lsof -t -i:80)
        sudo kill -9 $PID
        echo -e "${GREEN}✓ Stopped process on port 80${NC}"
    else
        echo -e "${YELLOW}Please manually stop the service or change the port in docker-compose.yml${NC}"
        exit 1
    fi
fi

cd .. || exit

# Step 1: Create data directories
echo -e "${YELLOW}📁 Creating data directories...${NC}"
mkdir -p crop_dashboard/data/models
mkdir -p crop_dashboard/data/json
mkdir -p data

# Step 2: Navigate to Docker directory
cd Docker || exit

# Step 3: Build Docker images (WITH CACHE - much faster!)
echo -e "${YELLOW}🐳 Building Docker images with cache...${NC}"
docker-compose build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed! Check errors above.${NC}"
    exit 1
fi

# Step 4: Start containers
echo -e "${YELLOW}🚀 Starting containers...${NC}"
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start containers!${NC}"
    echo -e "${YELLOW}Checking logs...${NC}"
    docker-compose logs
    exit 1
fi

# Step 5: Smart wait for services
echo -e "${YELLOW}⏳ Waiting for services to initialize...${NC}"
echo -n "   "
for i in {1..15}; do
  echo -n "▓"
  sleep 1
done
echo ""

# Step 6: Verify containers are running
echo -e "${YELLOW}🔍 Verifying containers...${NC}"
CONTAINERS_RUNNING=0
for container in spark-master spark-worker-1 spark-worker-2; do
  if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    echo -e "${GREEN}   ✓ ${container} is running${NC}"
    ((CONTAINERS_RUNNING++))
  else
    echo -e "${RED}   ✗ ${container} failed to start${NC}"
    echo -e "${YELLOW}   Checking logs for ${container}:${NC}"
    docker logs ${container} 2>&1 | tail -n 10
  fi
done

if [ $CONTAINERS_RUNNING -lt 3 ]; then
    echo -e "${RED}❌ Not all containers started successfully!${NC}"
    echo -e "${YELLOW}Run 'docker-compose logs' for details${NC}"
    exit 1
fi

# Step 7: Install dependencies in containers (parallel for speed)
echo -e "${YELLOW}📦 Installing Python packages in parallel...${NC}"
(docker exec spark-master pip install --quiet scikit-learn joblib pandas 2>&1 | sed 's/^/   [master] /') &
(docker exec spark-worker-1 pip install --quiet scikit-learn joblib pandas 2>&1 | sed 's/^/   [worker-1] /') &
(docker exec spark-worker-2 pip install --quiet scikit-learn joblib pandas 2>&1 | sed 's/^/   [worker-2] /') &
wait

# Step 8: Final health check
echo ""
echo -e "${YELLOW}🏥 Final health check...${NC}"
HEALTHY=true

# Check Spark Master
if curl -s http://localhost:8080 > /dev/null 2>&1; then
  echo -e "${GREEN}   ✓ Spark Master UI accessible${NC}"
else
  echo -e "${RED}   ✗ Spark Master UI not accessible${NC}"
  HEALTHY=false
fi

# Check Dashboard
if curl -s http://localhost > /dev/null 2>&1; then
  echo -e "${GREEN}   ✓ Dashboard accessible${NC}"
else
  echo -e "${RED}   ✗ Dashboard not accessible${NC}"
  HEALTHY=false
fi

# Check Jupyter
if curl -s http://localhost:8888 > /dev/null 2>&1; then
  echo -e "${GREEN}   ✓ Jupyter accessible${NC}"
else
  echo -e "${RED}   ✗ Jupyter not accessible${NC}"
  HEALTHY=false
fi

# Step 9: Success message
echo ""
if [ "$HEALTHY" = true ]; then
    echo -e "${GREEN}✅ Setup complete! All services are healthy!${NC}"
else
    echo -e "${YELLOW}⚠️  Setup complete but some services may need troubleshooting${NC}"
fi

echo ""
echo "📊 Access Points:"
echo "  ┌─────────────────────────────────────────────────┐"
echo "  │ Jupyter Notebook:  http://localhost:8888        │"
echo "  │ Spark Master UI:   http://localhost:8080        │"
echo "  │ Dashboard:         http://localhost/            │"
echo "  │ Worker 1 UI:       http://localhost:8081        │"
echo "  │ Worker 2 UI:       http://localhost:8082        │"
echo "  └─────────────────────────────────────────────────┘"
echo ""
echo "📝 Quick Start Workflow:"
echo "  1. Open Jupyter: http://localhost:8888"
echo "  2. Run notebook: YieldDataAnalysis.ipynb"
echo "  3. Generate predictions:"
echo -e "     ${BLUE}docker exec -it spark-master python3 /var/www/html/crop_yield_prediction.py${NC}"
echo "  4. View dashboard: http://localhost/"
echo ""
echo "🛠️  Useful Commands:"
echo -e "  Status:  ${BLUE}docker ps${NC}"
echo -e "  Logs:    ${BLUE}docker logs -f spark-master${NC}"
echo -e "  Stop:    ${BLUE}docker-compose down${NC}"
echo -e "  Restart: ${BLUE}docker-compose restart${NC}"
echo ""
echo -e "${GREEN}🎉 Ready to go!${NC}"
