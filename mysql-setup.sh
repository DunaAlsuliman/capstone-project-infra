#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy curl git

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh 

docker run -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 -d mysql