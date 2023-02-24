#!/bin/bash

# install and configure docker on the ec2 instance
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker

# pull the image you previously built and pushed locally (make sure to replace the line with your contents)
sudo docker pull  your-dockerhub-username/repo-for-shortener

# start the container  
sudo docker run -d -p  8000:8000 your-dockerhub-username/repo-for-shortener:latest


