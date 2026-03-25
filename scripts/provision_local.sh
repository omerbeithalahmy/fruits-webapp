#/bin/bash
set -e

echo "Starting the app"

echo "Building and starting containers"
docker compose up --build -d

echo "Waiting for DB to seed and App to initialize"
sleep 5

echo "Architecture is up and running"
echo "You can open your browser and navigate to http://localhost:3000"