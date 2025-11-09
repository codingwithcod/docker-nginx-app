#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Installing Docker & Docker Compose on Ubuntu"
echo "=========================================="

# Step 1: Remove old versions
echo "🧹 Removing old Docker versions (if any)..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Step 2: Update and install dependencies
echo "📦 Updating system and installing prerequisites..."
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# Step 3: Add Docker’s official GPG key
echo "🔑 Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Step 4: Add Docker repository
echo "🧩 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Install Docker Engine, CLI, and Compose plugin
echo "⚙️ Installing Docker Engine and Docker Compose..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 6: Enable and start Docker
echo "🔄 Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Step 7: Add current user to docker group
echo "👤 Adding current user ($USER) to docker group..."
sudo usermod -aG docker $USER
sudo newgrp docker

# Step 8: Verify installation
echo "✅ Verifying installation..."
docker --version
docker compose version

echo "🎉 Docker installation completed successfully!"
echo "👉 Please log out and log back in, or run: newgrp docker"
echo "Then test Docker by running: docker run hello-world"
