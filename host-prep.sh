#!/bin/bash
# Make kolla a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Remove the hosts entries created by default (or else RabbitMQ fails)
sudo cp ~/kolla-fountain/etc/hosts /etc/kolla/hosts
# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
