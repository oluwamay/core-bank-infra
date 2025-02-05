#!/bin/bash

#sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

#install nginx
apt-get update
apt-get install -y nginx

#make sure nginx is started
service nginx start