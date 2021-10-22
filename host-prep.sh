#!/bin/bash
# Make kolla user a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
# Change the hosts entry to match to the kolla_internal_vip_address 
sudo sed -i '/127.0.0.1 localhost/d' /etc/hosts
sudo sed -i '/127.0.0.1 singlet/d' /etc/hosts
