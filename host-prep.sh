#!/bin/bash
# Remove the hosts entries createed dby default (or else RabbitMQ fails)
sudo sed -i '1,2d' /etc/hosts
# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
