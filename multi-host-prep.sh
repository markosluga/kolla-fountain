#!/bin/bash
# Make kolla a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Remove the hosts entries createed dby default (or else RabbitMQ fails)
sudo cp ~/kolla-fountain/etc/hosts /etc/hosts
# copy your ssh files to kolla .ssh directory
cp ~/kolla-fountain/home/kolla/.ssh/* ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 400 ~/.ssh/id_rsa
# Install prerequisites and kolla-ansible
sudo apt update
sudo apt install -y docker.io python3-dev libffi-dev gcc libssl-dev sudo python3-pip
sudo pip3 install -U pip
sudo pip3 install -U ansible==2.10
sudo apt install -y ansible
sudo pip3 install -U docker
sudo pip3 install -U kolla-ansible
