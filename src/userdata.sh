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


curl -L 'https://huggingface.co/acheong08/f222/resolve/main/f222.ckpt' \
     -o /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion/f222.ckpt

# keyword: mdjrny-v4 style
curl -L 'https://huggingface.co/prompthero/openjourney/resolve/main/mdjrny-v4.ckpt' \
     -o /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion/mdjrny-v4.ckpt


# keyword: nvinkpunk
curl -L 'https://huggingface.co/Envvi/Inkpunk-Diffusion/resolve/main/Inkpunk-Diffusion-v2.ckpt' \
     -o /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion/inkpunk-diffusion.ckpt

curl -L 'https://huggingface.co/SG161222/Realistic_Vision_V2.0/resolve/main/Realistic_Vision_V2.0.ckpt' \
     -o /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion/realistic-vision-v2.ckpt


cat << EOF > /etc/systemd/system/webui.service
[Unit]
Description=webui
After=syslog.target
After=network.target
[Service]
ExecStart=/home/ubuntu/stable-diffusion-webui/webui.sh
Type=simple
Restart=always
User=ubuntu
Group=ubuntu
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable webui

bash stable-diffusion-webui/setup.sh -y
# sudo systemctl start webui

