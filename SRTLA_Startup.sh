#!/bin/bash

set -e

echo "=== [1/4] apt update && install prerequisites ==="
apt update
apt install -y ca-certificates curl gnupg lsb-release ufw

echo "=== [2/4] Install Docker ==="
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

echo "=== [3/4] Run Belabox Receiver container with restart=always ==="
docker run -d \
  --name belabox \
  --restart=always \
  -p 8181:8181/tcp \
  -p 8282:8282/udp \
  -p 5000:5000/udp \
  luminousaj/belabox-receiver:latest

echo "=== [4/4] Configure UFW (Firewall) ==="
ufw allow 8181/tcp
ufw allow 8282/udp
ufw allow 5000/udp
ufw --force enable

echo "=== Setup completed successfully ==="