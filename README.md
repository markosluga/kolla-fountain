# The kolla-fountain v.1.2.1

## An easy way to deploy OpenStack with kolla.

* Install Ubuntu 20.04.3 on one or more nodes.
* Create a user called kolla - you can use the [user-kolla.sh](https://github.com/markosluga/kolla-fountain/blob/main/user-kolla.sh) script if you like. If you are going to use any other user other than kolla please change line 4 in [all-in-one](https://github.com/markosluga/kolla-fountain/blob/main/home/kolla/all-in-one) and swap 
`ansible_user=kolla` with your username
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

In later iterrations I enabled a small DHCP on the tunnel and provider networks just to bring the adapters up and it works the same. An example of that netplan is [here](https://github.com/markosluga/kolla-fountain/blob/main/etc/netplan/01-installer-config.yaml). As you can see I also opted for a static IP for eth0 since I hardcoded my devices with a new domain .lan and set up a small DNS on my router.

# Getting startred:

## [host-prep.sh](https://github.com/markosluga/kolla-fountain/blob/main/host-prep.sh)

Host prep just prepares the host with kolla as a sudoer with no password (since the scripts are doing a lot of sudo) and then adds the pv and vg for cinder

* Replace /dev/sdb with your cinder device(s) at line 6 and 7 in host-prep.sh

`sudo pvcreate /dev/sdb`

`sudo vgcreate cinder-volumes /dev/sdb`

## [kolla-post-install.sh](https://github.com/markosluga/kolla-fountain/blob/main/kolla-post-install.sh)

1. Installs openstack client
2. Runs the pos-install kolla task.
3. Exports authentication
4. Crerates a Cirros image
5. Creates a 1CPU-1GB RAM flavor
6. Creates the provider networks and subnets
7. Creates a private network and subnet
8. Creates a neutron router and connects it to the networks.
9. Displays the login password for the admin user

* You need to *change the default networks* to match your subnet ranges

For example 192.168.79.x needs to be changed to your external network here:

openstack network create  --share --external --provider-physical-network physnet1 --provider-network-type flat provider1
openstack subnet create --network provider1 --gateway 192.168.79.1 --subnet-range 192.168.79.1/24  subnet1 --allocation-pool start=192.168.79.101,end=192.168.79.150

## [deploy-single.sh](https://github.com/markosluga/kolla-fountain/blob/main/deploy-single.sh) and [deploy-multi.sh](https://github.com/markosluga/kolla-fountain/blob/main/deploy-multi.sh)

Once you have edited the files above you can run the single or multi-node deployment script on the node of your choice.

# Single node

## [kolla-shaker-single.sh](https://github.com/markosluga/kolla-fountain/blob/main/kolla-shaker-single.sh)

Deploys all the packages required to run kolla ansible and configures ansible and an all-in-one kolla deployment. Unless you are changing versions of kolla/ansible/python no changes are needed. **This deployment does not use a python virtual environment!**

1. Please edit ~/kolla-fountain/etc/kolla/globals.yml replacing the following with your values:

openstack_release: "wallaby" # change this to your desired version!
kolla_internal_vip_address: "192.168.1.100" # change this IP to your IP!
network_interface: "eth0" # change this to your mgmt adapter!
api_interface: "{{ network_interface }}"
tunnel_interface: "eth1" # change this to your private networks adapter!
neutron_bridge_name: "br-ex,br-ex2" # change the number of external brisges to the number of external adapters
neutron_external_interface: "eth2,eth3" # change this to your external adapters adapter!

Now you are ready to deploy with [deploy-single.sh](https://github.com/markosluga/kolla-fountain/blob/main/deploy-multi.sh)

# Multi node

## [kolla-shaker-multi.sh](https://github.com/markosluga/kolla-fountain/blob/main/kolla-shaker-multi.sh)

Deploys the packages on multiple nodes. Replaces the multinode kolla ansible file with the one in ~/kolla-fountain/home/kolla/multinode and copies the ssh data to kolla home .ssh.

1. Create your .ssh files: **private and public key, authorized hosts and known hosts**. Store the files in the [kolla-fountain/home/kolla/.ssh](https://github.com/markosluga/kolla-fountain/tree/main/home/kolla/.ssh) folder. These files will be deployed to all nodes by [multi-host-prep.sh](https://github.com/markosluga/kolla-fountain/blob/main/multi-host-prep.sh). which will also passwordless sudo for the kolla user.

2. Run [multi-host-prep.sh](https://github.com/markosluga/kolla-fountain/blob/main/multi-host-prep.sh) on **all** nodes beofre you run the multinode deployment.

3. Run [cinder-node-prep.sh](https://github.com/markosluga/kolla-fountain/blob/main/cinder-node-prep.sh) on your storage nodes.

4. Edit [~/kolla-fountain/home/kolla/multinode](https://github.com/markosluga/kolla-fountain/home/kolla/multinode)

Multiple host format is *host[startnumber,endnumber]* - kolla[02:03] represents hosts kolla02 and kolla03, kolla[02:04] represents hosts kolla02, kolla03 and kolla04.

Replace the following:

[control]
kolla[05:06] ansible_user=kolla ansible_become=true # repalce with your controller nodes
 
[network]
kolla[02:03] # repalce with your network nodes

[compute]
kolla[07:08] # repalce with your compute nodes

[monitoring]
kolla[05:06] # repalce with your monitoring nodes (usually controllers)

[storage]
kolla[07:08] # repalce with your cinder (storage) nodes

5. Just like for the single nodes please also edit ~/kolla-fountain/etc/kolla/globals.yml replacing the following with your values:

openstack_release: "wallaby" # change this to your desired version!
kolla_internal_vip_address: "192.168.1.100" # change this IP to an unused IP of your management network NOT the host IP!
network_interface: "eth0" # change this to your management network adapter!
tunnel_interface: "eth1" # change this to your private networks adapter!
neutron_bridge_name: "br-ex,br-ex2" # change the number of external brisges to the number of external adapters
neutron_external_interface: "eth2,eth3" # change this to your external adapters adapter!

6. Now you are ready to deploy with [deploy-multi.sh](https://github.com/markosluga/kolla-fountain/blob/main/deploy-multi.sh) on any of the nodes that you are working on.

(c) marko@markocloud.com


