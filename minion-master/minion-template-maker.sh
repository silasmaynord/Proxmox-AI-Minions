# Install the Salt Minion as a template LXC, Debian 12, with the following commands
sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://saltproject.io
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://saltproject.io bookworm main" | sudo tee /etc/apt/sources.list.d/salt.list
sudo apt update && sudo apt install salt-minion -y

# Point the minion to your Master's IP address
echo "master: <YOUR_SALT_MASTER_IP>" | sudo tee /etc/apt/salt/minion.d/master.conf

# IMPORTANT: Remove the minion ID so clones generate unique keys on boot
sudo rm -f /etc/salt/minion_id
