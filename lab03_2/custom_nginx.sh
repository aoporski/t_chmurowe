#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Użycie: $0 <host_port> <ścieżka do nginx.conf> [ścieżka do index.html]"
    exit 1
fi

HOST_PORT=$1
NGINX_CONF=$2
INDEX_HTML=${3:-"./index.html"}

if [ ! -f "$NGINX_CONF" ]; then
    echo "Brak pliku nginx.conf: $NGINX_CONF"
    exit 1
fi

if [ ! -f "$INDEX_HTML" ]; then
    echo "Brak pliku index.html: $INDEX_HTML"
    exit 1
fi

CONTAINER_PORT=$(grep "listen" "$NGINX_CONF" | sed -E 's/.*listen[[:space:]]+([0-9]+).*/\1/' | head -n1)

if [ -z "$CONTAINER_PORT" ]; then
    echo "Nie znaleziono portu w nginx.conf. Upewnij się, że masz wpis typu: listen <port>;"
    exit 1
fi

echo "Znaleziony port w nginx.conf: $CONTAINER_PORT"

docker rm -f custom-nginx-container 2>/dev/null || true

TMP_DIR=$(mktemp -d)
cp "$NGINX_CONF" "$TMP_DIR/nginx.conf"
cp "$INDEX_HTML" "$TMP_DIR/index.html"

cat > "$TMP_DIR/Dockerfile" <<EOF
FROM nginx:latest
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
EOF

docker build --platform linux/amd64 -t custom-nginx "$TMP_DIR"
docker run --platform linux/amd64 -d --name custom-nginx-container -p $HOST_PORT:$CONTAINER_PORT custom-nginx

echo "Nginx ruszył: http://localhost:$HOST_PORT -> listen $CONTAINER_PORT w kontenerze"

trap "rm -rf $TMP_DIR" EXIT
