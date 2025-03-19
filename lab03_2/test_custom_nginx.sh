#!/bin/bash

SCRIPT="./custom_nginx.sh"
TEST_PORT=8095
TEST_CONTENT="Hello"
TMP_HTML="./temp_index.html"
TMP_CONF="./temp_nginx.conf"

echo "$TEST_CONTENT" > "$TMP_HTML"

cat > "$TMP_CONF" <<EOF
events {}
http {
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

bash $SCRIPT $TEST_PORT "$TMP_CONF" "$TMP_HTML"
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

docker rm -f custom-nginx-container > /dev/null
rm "$TMP_HTML" "$TMP_CONF"
echo "Cleaned up after tests."
