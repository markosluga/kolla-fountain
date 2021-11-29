#/bin/bash

# configure kolla etc files
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla

#copy the globals.yml file from the sample in the home directory
cp ~/kolla-fountain/etc/kolla/globals.yml /etc/kolla/globals.yml
cp /usr/local/share/kolla-ansible/ansible/inventory/* ~

#generate passwords
kolla-genpwd

# Create folders and copy neutron ml2_conf.ini
sudo mkdir /etc/kolla/config/
sudo mkdir /etc/kolla/config/neutron
sudo chown $USER:$USER /etc/kolla/config
sudo chown $USER:$USER /etc/kolla/config/neutron/
cp ~/kolla-fountain/etc/kolla/neutron/ml2_conf.ini /etc/kolla/config/neutron/ml2_conf.ini

# Set up ansible for kolla
sudo cp ~/kolla-fountain/etc/ansible/ansible.cfg /etc/ansible/ansible.cfg

# Set up kolla all-in-one 
cp ~/kolla-fountain/home/kolla/multinode ~/multinode
