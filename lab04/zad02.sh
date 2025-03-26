#!/bin/bash

docker volume create nginx_data
docker volume create nodejs_data
docker volume create all_volumes

docker rm -f my_nginx my_nodejs 2>/dev/null

docker run -d --name my_nginx --platform linux/amd64 -p 8080:80 -v nginx_data:/usr/share/nginx/html nginx

docker exec my_nginx sh -c 'echo "<h1>Witaj w Nginx!</h1>" > /usr/share/nginx/html/index.html'

docker run -d --name my_nodejs --platform linux/amd64 -v nodejs_data:/app node:latest sleep infinity

docker exec my_nodejs sh -c 'echo "console.log(\"Hello from Node.js!\");" > /app/server.js'

docker run --rm --name volume_helper \
  -v nginx_data:/nginx_data \
  -v nodejs_data:/nodejs_data \
  -v all_volumes:/all_volumes \
  alpine sh -c "cp -r /nginx_data/* /all_volumes/ && cp -r /nodejs_data/* /all_volumes/"

echo "Pliki zostały skopiowane do all_volumes"
