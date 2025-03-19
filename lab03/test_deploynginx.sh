#!/bin/bash

SCRIPT="./deploynginx.sh"
TEST_PORT=8090
TEST_CONTENT="Test"

TMP_HTML="./temp_index.html"
echo "$TEST_CONTENT" > "$TMP_HTML"

bash $SCRIPT $TEST_PORT "$TMP_HTML"
sleep 5

docker ps | grep -q "custom-nginx-container"
if [ $? -eq 0 ]; then
    echo "Test 1: Container is running."
else
    echo "Test 1: Container is NOT running."
    exit 1
fi

RESULT=$(curl -s http://localhost:$TEST_PORT)
echo "$RESULT" | grep -q "$TEST_CONTENT"
if [ $? -eq 0 ]; then
    echo "Test 2: Content is correct."
else
    echo "Test 2: Content is incorrect."
    exit 1
fi

# Sprzątanie
docker rm -f custom-nginx-container > /dev/null
rm "$TMP_HTML"
echo "🧹 Cleaned up after tests."
