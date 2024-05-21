#!/bin/bash

sudo yum -y install httpd
sudo systemctl enable httpd
sudo systemctl restart httpd
sed "s/HOSTNAME/$(hostname -i)/g" GEN/index.html_tpl > index.html
sudo mv index.html /var/www/html/.
sudo cp -R GEN/myhome /var/www/html/.

