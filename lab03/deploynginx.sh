#!/bin/bash

if [ -z "$1" ]; then
  echo "Użycie: $0 <port> [ścieżka do pliku index.html]"
  exit 1
fi

PORT=$1
INDEX_HTML=${2:-"./index.html"}

if [ ! -f "$INDEX_HTML" ]; then
  echo "Brak pliku index.html podanej ścieżki: $INDEX_HTML"
  exit 1
fi

echo "Removing existing container custom_nginx..."
docker rm -f custom-nginx-container 2>/dev/null || true

TMP_DIR=$(mktemp -d)
cp "$INDEX_HTML" "$TMP_DIR/index.html"

cat > "$TMP_DIR/Dockerfile" <<EOF
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EOF

docker build --platform linux/amd64 -t custom-nginx "$TMP_DIR"

docker run --platform linux/amd64 -d --name custom-nginx-container -p $PORT:80 custom-nginx

echo "Nginx ruszył pod http://localhost:$PORT z zawartością: $INDEX_HTML"

trap "rm -rf $TMP_DIR" EXIT
