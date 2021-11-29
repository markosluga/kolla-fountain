#!/bin/bash
# Make kolla a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Remove the hosts entries createed dby default (or else RabbitMQ fails)
sudo cp ~/kolla-fountain/etc/hosts /etc/hosts
# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
# copy your ssh files to kolla .ssh directory
cp ~/kolla-fountain/home/kolla/.ssh/* ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 400 ~/.ssh/id_rsa
