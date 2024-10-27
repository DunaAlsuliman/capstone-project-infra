#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy curl git

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh 


docker run -d -p 6379:6379 --name redis redis