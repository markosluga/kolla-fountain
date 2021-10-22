# The kolla-fountain

## An easy way to deploy OpenStack with kolla.

### To get started clone the repository and Replace the IP address to an availabe address on your adapter:

* Line 8 in kolla-shaker.sh

`sudo sed -i "31i kolla_internal_vip_address: \"172.20.208.200\" " /etc/kolla/globals.yml`

* Replace 172.20.208.200 with the IP of your cluster in
* Replace /dev/sdb with your cinder device(s)
