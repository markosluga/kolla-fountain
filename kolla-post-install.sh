#!/bin/bash
sudo apt install -y openvswitch-switch python3-openstackclient
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh
wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img -P ~
openstack image create Cirros --file ~/cirros-0.5.2-x86_64-disk.img --disk-format qcow2 --shared
openstack flavor create --public type.1C_1G --id auto --ram 1024 --disk 1 --vcpus 1
openstack network create  --share --external --provider-physical-network physnet1 --provider-network-type flat provider1
openstack subnet create --network provider1 --gateway 192.168.1.1 --subnet-range 192.168.1.1/24  subnet1
openstack network create  --share --external --provider-physical-network physnet2 --provider-network-type flat provider2
openstack subnet create --network provider2 --gateway 192.168.77.1 --subnet-range 192.168.77.1/24  subnet2
openstack network create private
openstack subnet create privsubnet --network private --subnet-range 192.0.123.0/24
openstack router create router1 
openstack router set router1 --external-gateway provider1
openstack router add subnet router1 privsubnet
echo "Log in to the web at http://172.20.208.200/ as \"admin\" with the following password: `sudo grep -Po '(?<=^export OS_PASSWORD=)\w*$' /etc/kolla/admin-openrc.sh` "
