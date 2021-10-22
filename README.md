# The kolla-fountain

## An easy way to deploy a single host OpenStack with kolla.

* Install Ubuntu 20.04.3
* Create a user called kolla
* Set up the networks. 
I am using 4 adapters, but you might not need that many

eth0 – management network – this is my local network and allows me to reach the internet during install. DHCP
eth1 – tunnel network – this represents the “host only” type of network where the VM private networks will get created on VxLANs. STATIC
eth2 – provider network #1 STATIC
eth3 – provider network #2 STATIC

See https://github.com/markosluga/kolla-fountain/blob/main/etc/netplan/00-installer-config.yaml for a reference netplan

# Getting startred:

## host-prep.sh

Host prep just prepares the host with kolla as a sudoer with no password (since the scripts are doing a lot of sudo) and then adds the pv and vg for cinder

* Replace /dev/sdb with your cinder device(s) at line 6 and 7 in host-prep.sh

`sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb`

## kolla-shaker.sh

Deploys all the packages required to run kolla ansible and configures ansible and an all-in-one kolla deployment. Unless you are changing versions of kolla/ansible/python no changes are needed. **This deployment does not use a python virtual environment**

## kolla-maker.sh

1. Configures globals.yml with the settings needed to get off the ground quickly. See the references that it deploys into globals.yml here: https://github.com/markosluga/kolla-fountain/blob/main/etc/kolla/globals.yml
2. Configures neutron ml2_conf.ini with the mappings of the adapters to the OpenVswitc. See the references that it deploys into ml2_conf.ini here:  https://github.com/markosluga/kolla-fountain/blob/main/etc/kolla/neutron/ml2_conf.ini

* Change the IP address to an availabe address on your adapter at line 8 in kolla-shaker.sh

`sudo sed -i "31i kolla_internal_vip_address: \"172.20.208.200\" " /etc/kolla/globals.yml`

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

## deploy.sh

Once you have aedityed the files you can run deploy.sh since it simply runs the host-prep.sh, kolla-shaker.sh, kolla-maker.sh and kolla-post-install.sh automatically.

(c) marko@markocloud.com


