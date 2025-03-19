#!/bin/bash

docker network create my-net || true

docker rm -f my-node-app my-nginx-container 2>/dev/null || true

cat > app.js <<EOF
const http = require('http');
const port = 3000;
const server = http.createServer((req, res) => {
    res.end('Hello from Node.js');
});
server.listen(port, () => {
    console.log(\`Node.js running on port \${port}\`);
});
EOF

cat > Dockerfile.node <<EOF
FROM node:18-alpine
WORKDIR /usr/src/app
COPY app.js .
CMD ["node", "app.js"]
EOF

docker build -t custom-node -f Dockerfile.node .
docker run -d --name my-node-app --network my-net custom-node

mkdir -p ./nginx_cache
chmod -R 755 ./nginx_cache

cat > nginx.conf <<EOF
worker_processes 1;
events { worker_connections 1024; }

http {
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m use_temp_path=off;

    upstream node_upstream {
        server my-node-app:3000;
    }

    server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;

        location / {
            proxy_pass http://node_upstream;
            proxy_cache my_cache;
            proxy_cache_valid 200 1m;
        }
    }
}
EOF

cat > Dockerfile.nginx <<EOF
FROM nginx:alpine
RUN apk add --no-cache openssl
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /var/cache/nginx && chown -R nginx:nginx /var/cache/nginx
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\
    -keyout /etc/nginx/ssl/server.key \\
    -out /etc/nginx/ssl/server.crt \\
    -subj "/C=US/ST=State/L=City/O=MyOrg/OU=Dev/CN=localhost"
CMD ["nginx", "-g", "daemon off;"]
EOF

docker build -t custom-nginx -f Dockerfile.nginx .
docker run -d --name my-nginx-container --network my-net -p 80:80 -p 443:443 custom-nginx

echo "Deployment completed. Nginx is available"

