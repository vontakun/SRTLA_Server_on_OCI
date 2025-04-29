#!/bin/bash

set -e

echo "=== [1/3] apt update && install prerequisites ==="
apt update
apt install -y ca-certificates curl gnupg lsb-release ufw

echo "=== [2/3] Install Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "=== [3/3] Run Belabox Receiver container with restart=always ==="
docker run -d \
  --name belabox \
  --restart=always \
  -p 8181:8181/tcp \
  -p 8282:8282/udp \
  -p 5000:5000/udp \
  luminousaj/belabox-receiver:latest

echo "=== Setup completed successfully ==="