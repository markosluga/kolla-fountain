# The kolla-fountain v.1.0.7

## An easy way to deploy OpenStack with kolla.

* Install Ubuntu 20.04.3 on one or more nodes.
* Create a user called kolla - you can use the [user-kolla.sh](https://github.com/markosluga/kolla-fountain/blob/main/user-kolla.sh) script if you like. 
* Log in as user kolla. Now you can also delete the default ubuntu user (for security) with the following command:

`sudo deluser --remove-home ubuntu`

* Set up the networks. 

I am using 4 adapters, but you might want to go with just one provider network or even merge the private and managment into one.

* eth0 – management network – this is my local network and allows me to reach the internet during install. DHCP
* eth1 – tunnel network – this represents the “host only” type of network where the VM private networks will get created on VxLANs. STATIC
* eth2 – provider network #1 STATIC
* eth3 – provider network #2 STATIC

Change eth0-3 to your device names.

* Note that the provider adapters are **supposed to be unconfigured**, but for me traffic didn't flow unless I put a static IP on the provider network, so I just configured them with am available IP in the provider range to ensure they were up before I ran the scripts.

See [example netplan](https://github.com/markosluga/kolla-fountain/blob/main/etc/netplan/00-installer-config.yaml) as reference.

# Getting startred:

## host-prep.sh

Host prep just prepares the host with kolla as a sudoer with no password (since the scripts are doing a lot of sudo) and then adds the pv and vg for cinder

* Replace /dev/sdb with your cinder device(s) at line 6 and 7 in host-prep.sh

`sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb`

# Single node

## kolla-shaker-single.sh

Deploys all the packages required to run kolla ansible and configures ansible and an all-in-one kolla deployment. Unless you are changing versions of kolla/ansible/python no changes are needed. **This deployment does not use a python virtual environment!**

# Multi node

## kolla-shaker-multi.sh

Deploys the packages on multiple nodes. Removes the default entries in the multinode kolla ansible file and replaces them with the hostnames for the deployment. 

Multiple host format is *host[startnumber,endnumber]* - kolla[02:03] represents hosts kolla02 and kolla03

Replace the following:

Line 25: Replace kolla[02:03] with the hostname or hostnames of your controller node(s): 

Line 27: Replace kolla04 with the hostname or hostnames of your network node(s)

Line 29: Replace kolla01 with the hostname or hostnames of your compute node(s)

Line 31: Replace kolla[02:03] with the hostname or hostnames of your montioring node(s)

Line 33: Replace kolla[01:04] with the hostname or hostnames of your montioring node(s)

## kolla-maker.sh

1. Configures globals.yml with the settings needed to get off the ground quickly. See the references that it deploys into globals.yml here: https://github.com/markosluga/kolla-fountain/blob/main/etc/kolla/globals.yml
2. Configures neutron ml2_conf.ini with the mappings of the adapters to the OpenVswitc. See the references that it deploys into ml2_conf.ini here:  https://github.com/markosluga/kolla-fountain/blob/main/etc/kolla/neutron/ml2_conf.ini

* Change the IP address to an availabe address on your adapter at line 8 in kolla-shaker.sh

`sudo sed -i "31i kolla_internal_vip_address: \"YOUR-IP-GOES-HERE\" " /etc/kolla/globals.yml`

* Change eth0 to your management adapter at line 9 in kolla-shaker.sh

`sudo sed -i "32i network_interface: \"YOUR-DEVICE1-GOES-HERE\" " /etc/kolla/globals.yml`

* Change eth1 to your tunnel adapter at line 11 in kolla-shaker.sh

`sudo sed -i "34i tunnel_interface: \"YOUR-DEVICE2-GOES-HERE\" " /etc/kolla/globals.yml`

* Change the neutron_external adapters to your physical devices at line 13 in kolla-shaker.sh

`sudo sed -i "36i neutron_external_interface: \"YOUR-DEVICE3-GOES-HERE,YOUR-DEVICE4-GOES-HERE\" " /etc/kolla/globals.yml`

## kolla-post-install.sh

1. Installs openstack client and ovs-vsctl
2. Runs the pos-install kolla task.
3. Exports authentication
4. Crerates a Cirros image
5. Creates a 1CPU-1GB RAM flavor
6. Creates the provider networks and subnets
7. Creates a private network and subnet
8. Creates a neutron router and connects it to the networks.
9. Displays the login password for the admin user

* Feel free to change these networks to match your subnet ranges

## nodes-multi.sh

Required to run on the nodes (not the deployment one) in a multinode scenario.

## deploy-single.sh and deploy-multi.sh

Once you have edited the files above you can run the single or multi-node deployment script on the node of your choice.

(c) marko@markocloud.com


