#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy curl git

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh 

git clone https://github.com/DunaAlsuliman/capstone-project.git

cd capstone-project

cat <<EOT > .env
REDIS_HOST=${redis_host}
DB_HOST=${mysql_host}
DB_USER=user
DB_PASSWORD=password
DB_NAME=mydatabase
EOT

docker build -t app .
docker run -d -p 80:5000 --name web  --env-file .env dunaalsulaiman/capstone-project:latest


