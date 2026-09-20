# Install the SaltStack Master Minion on a Proxmox LXC, Debian 12, as the management node
curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://saltproject.io
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://saltproject.io bookworm main" | sudo tee /etc/apt/sources.list.d/salt.list
apt update && sudo apt install salt-master -y
systemctl enable --now salt-master
