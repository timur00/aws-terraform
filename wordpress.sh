#!/bin/bash
sleep 10
sudo apt update 
sudo apt install mysql-client -y
sudo apt install apache2 apache2-utils -y
sudo apt install php7.2 php7.2-mysql libapache2-mod-php7.2 php7.2-cli php7.2-cgi php7.2-gd -y
sudo apt install php7.2-curl php7.2-gd php7.2-xmlrpc git binutils -y
sudo systemctl restart apache2
sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sleep 20
sudo mkdir -p /var/www/html/
sudo rsync -av wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo rm /var/www/html/index.html
sudo systemctl restart apache2
sleep 20
git clone https://github.com/aws/efs-utils && \
cd efs-utils && \
./build-deb.sh && \
sudo apt -y install ./build/amazon-efs-utils*deb 
sudo mkdir /var/www/html/wp-content/uploads/
sudo chmod 775 /var/www/html/wp-content/uploads/
sudo mount -t efs -o tls ${efs_id}:/  /var/www/html/wp-content/uploads/
sudo chown -R www-data.www-data /var/www/html/wp-content/uploads/
