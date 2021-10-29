#!/bin/bash
# Make kolla a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Remove the hosts entries createed dby default (or else RabbitMQ fails)
sudo sed -i '1,2d' /etc/hosts
# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
# Set static DNS
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo sed -i '17,19d' /etc/resolv.conf
sudo sed -i '16isearch lan' >> /etc/resolv.conf
sudo sed -i '16inameserver 192.168.1.1' >> /etc/resolv.conf
