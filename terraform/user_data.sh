#!/bin/bash
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Create Docker bridge network
docker network create --driver bridge clo835-net
