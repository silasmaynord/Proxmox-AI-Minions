To get started with in-place configuration management for your worker fleet, SaltStack is generally preferred over Puppet for rapid scaling because it uses a highly efficient, real-time message bus (ZeroMQ) that aligns perfectly with rapid multi-agent fleet operations.
Here is how to set up both environments to manage your active Proxmox linked clones.
------------------------------
## Option A: The SaltStack Approach (Recommended)
SaltStack uses a Master-Minion architecture. The Master dictates the configuration state, and the Minions (your clones) pull and execute those changes instantly.
## 1. Setup the Salt Master
Run these commands on a dedicated control VM or your master management node:

# Install the Salt Master
sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://saltproject.io
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://saltproject.io bookworm main" | sudo tee /etc/apt/sources.list.d/salt.list
sudo apt update && sudo apt install salt-master -y
sudo systemctl enable --now salt-master

## 2. Bake the Minion into your Base Template
To avoid configuring every clone manually, install the salt-minion on your temporary full clone before converting it back to a template:

# Install the Salt Minion
sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://saltproject.io
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://saltproject.io bookworm main" | sudo tee /etc/apt/sources.list.d/salt.list
sudo apt update && sudo apt install salt-minion -y
# Point the minion to your Master's IP address
echo "master: <YOUR_SALT_MASTER_IP>" | sudo tee /etc/apt/salt/minion.d/master.conf
# IMPORTANT: Remove the minion ID so clones generate unique keys on boot
sudo rm -f /etc/salt/minion_id

## 3. Accept Keys and Push States
When a new linked clone boots up, it will check in with the master.

* Accept the new keys: On the Master, view and accept the incoming clone keys by running salt-key -A -y.
* Push a provisioning change: Write a simple state file to update packages or files, then push it to every clone instantly using:

salt '*' state.apply


------------------------------
## Option B: The Puppet Approach
Puppet relies on a Puppetserver and target Agents. It operates on a declarative framework, enforcing configurations every 30 minutes by default.
## 1. Setup the Puppetserver
On your master node:

wget https://puppet.com
sudo dpkg -i puppet8-release-bookworm.deb
sudo apt update && sudo apt install puppetserver -y
sudo systemctl enable --now puppetserver

## 2. Pre-configure the Agent Template
On your base template VM:

wget https://puppet.com
sudo dpkg -i puppet8-release-bookworm.deb
sudo apt update && sudo apt install puppet-agent -y
# Configure the agent to look for the server
echo -e "[main]\nserver = <YOUR_PUPPETSERVER_HOSTNAME>" | sudo tee /etc/puppetlabs/puppet/puppet.conf
# Clean up SSL certs so clones don't copy the template's identity
sudo rm -rf /etc/puppetlabs/puppet/ssl/*

## 3. Sign Certificates

* When the clones boot up, they request a certificate.
* List incoming requests on the server using puppetserver ca list.
* Sign the clones with puppetserver ca sign --all. Clones will then periodically check in to pull updates defined in your /etc/puppetlabs/code/environments/production/manifests/site.pp script.

Which one would you like to build out first? If you choose SaltStack, I can help you write your first State file (.sls) to automate your specific AI worker configurations, or we can look into automating the minion key-acceptance process so new clones are authorized automatically.

