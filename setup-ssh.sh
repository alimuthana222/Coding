#!/bin/bash

# Update package lists
sudo apt update

# Install OpenSSH server
sudo apt install -y openssh-server

# Start SSH service
sudo systemctl start ssh

# Enable SSH service to start on boot
sudo systemctl enable ssh

# Configure SSH (optional, modify as needed)
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart ssh

# Print status
sudo systemctl status ssh
