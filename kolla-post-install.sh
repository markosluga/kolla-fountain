#!/bin/bash
sudo apt install -y python3-openstackclient
kolla-ansible post-deploy
# Export creds
. /etc/kolla/admin-openrc.sh
# Create image
wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img -P ~
openstack image create Cirros --file ~/cirros-0.5.2-x86_64-disk.img --disk-format qcow2 --shared
# Create flavor
openstack flavor create --public type.1C_1G --id auto --ram 1024 --disk 1 --vcpus 1
#Create provider networks
openstack network create  --share --external --provider-physical-network physnet1 --provider-network-type flat provider1
openstack subnet create --network provider1 --gateway 192.168.79.1 --subnet-range 192.168.79.0/24  subnet1 --allocation-pool start=192.168.79.101,end=192.168.79.150
openstack network create  --share --external --provider-physical-network physnet2 --provider-network-type flat provider2
openstack subnet create --network provider2 --gateway 192.168.80.1 --subnet-range 192.168.80.0/24  subnet2 --allocation-pool start=192.168.80.101,end=192.168.80.150
# Create private network
openstack network create private1
openstack subnet create privsubnet1 --network private1 --subnet-range 192.168.123.0/24
openstack network create private2
openstack subnet create privsubnet2 --network private2 --subnet-range 192.168.124.0/24
# Create router
openstack router create router1
openstack router set router1 --external-gateway provider1
openstack router add subnet router1 privsubnet1
openstack router add subnet router1 privsubnet2
# Display password
echo "Log in as \"admin\" with the following password: `sudo grep -Po '(?<=^export OS_PASSWORD=)\w*$' /etc/kolla/admin-openrc.sh` "
