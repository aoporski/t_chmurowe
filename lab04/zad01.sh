#!/bin/bash

docker volume create nginx_data

docker rm -f my_nginx_1 2>/dev/null

docker run -d --name my_nginx_1 --platform linux/amd64 -p 8080:80 -v nginx_data:/usr/share/nginx/html nginx

sleep 1

if ! docker ps --format '{{.Names}}' | grep -q '^my_nginx_1$'; then
    echo "Error"
fi

docker exec my_nginx_1 sh -c 'echo "<h1>Witaj w Nginx!</h1><p>Serwer działa poprawnie.</p>" > /usr/share/nginx/html/index.html'

echo "http://localhost:8080"
