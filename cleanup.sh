#!/bin/bash
# cleanup.sh - Run this before setup.sh

echo "🧹 Cleaning up Docker environment..."

# Stop all spark containers
docker stop $(docker ps -a -q --filter="name=spark") 2>/dev/null
docker rm $(docker ps -a -q --filter="name=spark") 2>/dev/null

# Remove networks
docker network rm docker_spark-network 2>/dev/null

# Kill anything on port 80
sudo lsof -ti:80 | xargs sudo kill -9 2>/dev/null

echo "✅ Cleanup complete! Now run setup.sh"
