#!/bin/bash
sudo apt install -y openvswitch-switch python3-openstackclient
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh
