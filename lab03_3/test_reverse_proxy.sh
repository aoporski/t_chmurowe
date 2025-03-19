#!/bin/bash

docker ps | grep -q "my-node-app"
if [ $? -eq 0 ]; then
    echo "Test 1: Node.js container running."
else
    echo "Test 1: Node.js container not running."
    exit 1
fi

docker ps | grep -q "my-nginx-container"
if [ $? -eq 0 ]; then
    echo "Test 2: Nginx container running."
else
    echo "Test 2: Nginx container not running."
    exit 1
fi

sleep 5
RESULT=$(curl -sk http://localhost)
echo "$RESULT" | grep -q "Hello from Node.js"
if [ $? -eq 0 ]; then
    echo "Test 3: Reverse proxy HTTP works."
else
    echo "Test 3: Reverse proxy HTTP failed."
    exit 1
fi

RESULT_SSL=$(curl -sk https://localhost)
echo "$RESULT_SSL" | grep -q "Hello from Node.js"
if [ $? -eq 0 ]; then
    echo "Test 4: Reverse proxy HTTPS works."
else
    echo "Test 4: Reverse proxy HTTPS failed."
    exit 1
fi

docker rm -f my-node-app my-nginx-container
docker network rm my-net
echo "Cleanup completed."

