# The kolla-fountain

## An easy way to deploy OpenStack with kolla.

### To get started clone the repository and replace the following:

* Replace /dev/sdb with your cinder device(s) at line 6 and 7 in host-prep.sh

`sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb'

* IP address to an availabe address on your adapter at line 8 in kolla-shaker.sh

`sudo sed -i "31i kolla_internal_vip_address: \"172.20.208.200\" " /etc/kolla/globals.yml`



