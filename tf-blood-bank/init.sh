#!/bin/bash

set -x

dbname=bloodbank

sudo apt update

sudo apt install -y dnsutils curl
sudo apt install -y nginx
sudo apt install -y php-fpm
sudo apt install -y certbot python3-certbot-nginx

sudo mkdir -p /var/www/itsprout.online

cat << EOF | sudo tee /etc/nginx/sites-available/itsprout.online > /dev/null
server {
  listen 80 ;
  listen [::]:80 ;
  
  server_name itsprout.online www.itsprout.online;
  root /var/www/itsprout.online;
  index index.html index.htm index.php;

  location / {
    try_files \$uri \$uri/ =404;
  }

  location ~ .php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
  }

  location ~ /.ht {
    deny all;
  }
}

EOF

sudo ln -s /etc/nginx/sites-available/itsprout.online /etc/nginx/sites-enabled/

current_public_ip=$(curl ipconfig.io)
current_dns_a_record=$(dig +short itsprout.online | tail -n1)

sudo certbot -n -d itsprout.online --nginx --agree-tos --email I.Tka4yk@gmail.com

sudo apt install -y mariadb-server mariadb-client

sudo mysql_secure_installation --use-default
sudo apt install -y php-mysql

cd /var/www/itsprout.online
sudo apt install -y git
sudo git clone https://github.com/mentorchita/Blood-Bank-Management-System .

sudo mysql --execute="CREATE DATABASE $dbname;"
sudo mysql bloodbank < ./sql/bloodbank.sql

sudo mysql --execute="CREATE USER 'bloodbank'@'localhost' IDENTIFIED BY 'Olomoutc';"
sudo mysql --execute="GRANT ALL PRIVILEGES ON bloodbank.* TO 'bloodbank'@'localhost';"
sudo mysql --execute="FLUSH PRIVILEGES;"

sudo sed -i 's/$username = "root";/$username = "bloodbank";/g' /var/www/itsprout.online/file/connection.php
sudo sed -i 's/$password = "";/$password = "Olomoutc";/g' /var/www/itsprout.online/file/connection.php


sudo systemctl restart nginx


