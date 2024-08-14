#!/bin/bash

# Start the Selenium Hub
echo "Starting Selenium Hub..."
docker run -d -p 4444:4444 --name selenium-hub selenium/hub:latest

# Start Chrome Nodes
echo "Starting Chrome Nodes..."
docker run -d --link selenium-hub:hub selenium/node-chrome:latest
docker run -d --link selenium-hub:hub selenium/node-chrome:latest

# Start Firefox Nodes
echo "Starting Firefox Nodes..."
docker run -d --link selenium-hub:hub selenium/node-firefox:latest
docker run -d --link selenium-hub:hub selenium/node-firefox:latest

# Optionally, you can add more nodes or configure specific capabilities

# Display status
echo "Selenium Grid setup completed."
echo "Hub is running at: http://localhost:4444/grid/console"
