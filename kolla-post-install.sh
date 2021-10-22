#!/bin/bash
sudo apt install -y openvswitch-switch python3-openstackclient
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh
wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-aarch64-disk.img -P ~
openstack image create Cirros-CLI --file ~/cirros-0.5.2-aarch64-disk.img --disk-format raw --container-format bare --private
openstack flavor create --public type.1C_1G --id auto --ram 0 --disk 0 --vcpus 1
openstack network create  --share --external --provider-physical-network physnet1 --provider-network-type flat provider1
openstack subnet create --network provider1 --gateway 192.168.1.1 --subnet-range 192.168.1.1/24  subnet1
openstack network create  --share --external --provider-physical-network physnet2 --provider-network-type flat provider2
openstack subnet create --network provider2 --gateway 192.168.77.1 --subnet-range 192.168.77.1/24  subnet2
openstack network create private
openstack subnet create privsubnet --network private --subnet-range 192.0.123.0/24
openstack router create router1 
openstack router set router1 --external-gateway provider1
openstack router add subnet privsubnet router1
