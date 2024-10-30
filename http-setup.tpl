#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy curl git

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh 

git clone https://github.com/DunaAlsuliman/capstone-project.git

cd capstone-project

echo "REDIS_HOST=${redis_host}" > .env
docker compose up -d