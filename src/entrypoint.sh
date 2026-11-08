#!/bin/sh
# IT-Tools is a static SPA served by nginx. The upstream image starts nginx as
# root on port 80; TOS forbids root containers, so run nginx as uid 1000 on
# 8080 with every pid/temp/log path redirected to /tmp.
set -u

mkdir -p /tmp/nginx/client_temp /tmp/nginx/proxy_temp /tmp/nginx/fastcgi_temp \
         /tmp/nginx/uwsgi_temp /tmp/nginx/scgi_temp

cat > /tmp/nginx.conf <<'EOF'
worker_processes 1;
pid /tmp/nginx.pid;
error_log /dev/stderr warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;
    sendfile on;
    client_body_temp_path /tmp/nginx/client_temp;
    proxy_temp_path /tmp/nginx/proxy_temp;
    fastcgi_temp_path /tmp/nginx/fastcgi_temp;
    uwsgi_temp_path /tmp/nginx/uwsgi_temp;
    scgi_temp_path /tmp/nginx/scgi_temp;

    server {
        listen 8080;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

exec nginx -c /tmp/nginx.conf -g 'daemon off;'
