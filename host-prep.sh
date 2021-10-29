#!/bin/bash
# Make kolla a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Remove the hosts entries createed dby default (or else RabbitMQ fails)
sudo sed -i '1,2d' /etc/hosts
# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
mkdir ~/.ssh
cp home/kolla/.ssh/* ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 400 ~/.ssh/id_rsa
