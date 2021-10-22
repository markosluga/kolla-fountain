#!/bin/bash
# Make kolla user a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Change the hosts entry to match to the kolla_internal_vip_address 
sudo sed -i '1,2d' /etc/hosts
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
