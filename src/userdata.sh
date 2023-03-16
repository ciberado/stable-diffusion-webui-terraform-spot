#!/bin/bash

apt update
apt install nginx -y
sed -i 's/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 512/' /etc/nginx/nginx.conf
sed -i '/server_names_hash_bucket_size/a proxy_headers_hash_max_size 512;' /etc/nginx/nginx.conf
sed -i '/server_names_hash_bucket_size/a proxy_headers_hash_bucket_size 128;' /etc/nginx/nginx.conf

cat << EOF > /etc/nginx/sites-enabled/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;


    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass  http://127.0.0.1:7860/;
    }
}
EOF
service nginx restart

cd /home/ubuntu
git clone https://github.com/marshmellow77/stable-diffusion-webui.git
echo "fastapi==0.90.0" >> stable-diffusion-webui/requirements_versions.txt

bash stable-diffusion-webui/setup.sh -y
bash stable-diffusion-webui/webui.sh