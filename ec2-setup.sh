#!/bin/bash

echo "Running setup..."

# Exit on any error
set -e

echo "Moving to correct directory"
cd /home/ubuntu

echo "Updating apt and installing required packages"
sudo apt update
sudo apt install -y \
    docker.io \
    unzip \
    curl \
    git

echo "Installing docker if not installed"
if ! command -v docker &> /dev/null; then
    sudo apt install -y docker.io
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
fi

echo "Installing nvm if not installed"
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Add NVM to .bashrc if not already there
    if ! grep -q "NVM_DIR" ~/.bashrc; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    fi

    # Install Node.js
    nvm install 18
    nvm alias default 18
fi

echo "Installing aws cli if not installed"
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    # Clean up downloaded files
    rm -rf aws awscliv2.zip
fi  

echo "Adding user to docker group"
sudo usermod -aG docker $USER

echo "Setup complete! Please log out and log back in for docker group changes to take effect."

# Verify installations
echo "Verifying installations...";
docker --version
node --version
aws --version
