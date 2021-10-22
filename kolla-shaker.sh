#/bin/bash
# Install prerequisites and kolla-ansible
# Create kolla-shaker.sh and add the following contents to the file:
sudo apt update
sudo apt install -y docker.io python3-dev libffi-dev gcc libssl-dev sudo python3-pip ansible
sudo pip3 install -U pip
sudo pip3 install -U docker
sudo pip3 install -U kolla-ansible
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* ~
kolla-genpwd
sudo mkdir /etc/kolla/config/
sudo mkdir /etc/kolla/config/neutron
sudo chown $USER:$USER /etc/kolla/config
sudo chown $USER:$USER /etc/kolla/config/neutron/
# Set up ansible for kolla
sudo sed -i "11i host_key_checking=False" /etc/ansible/ansible.cfg
sudo sed -i "12i pipelining=True" /etc/ansible/ansible.cfg
sudo sed -i "13i forks=100" /etc/ansible/ansible.cfg
# Set up kolla all-in-one 
sed -i '4s/$/localhost	ansible_connection=local ansible_user=kolla ansible_become=true/' ~/all-in-one
sed -i '19s/$/localhost       ansible_connection=local become=true/' ~/all-in-one
# Configure kolla globals
sudo sed -i "27i config_strategy: \"COPY_ALWAYS\" " /etc/kolla/globals.yml
sudo sed -i "28i kolla_base_distro: \"ubuntu\" " /etc/kolla/globals.yml
sudo sed -i "29i kolla_install_type: \"binary\" " /etc/kolla/globals.yml
sudo sed -i "30i openstack_release: \"wallaby\" " /etc/kolla/globals.yml
sudo sed -i "31i kolla_internal_vip_address: \"172.25.216.200\" " /etc/kolla/globals.yml
sudo sed -i "32i network_interface: \"eth0\" " /etc/kolla/globals.yml
sudo sed -i "33i api_interface: \"{{ network_interface }}\" " /etc/kolla/globals.yml
sudo sed -i "34i tunnel_interface: \"eth1\" " /etc/kolla/globals.yml
sudo sed -i "35i neutron_bridge_name: \"br-ex,br-ex2\" " /etc/kolla/globals.yml
sudo sed -i "36i neutron_external_interface: \"eth2,eth3\" " /etc/kolla/globals.yml
sudo sed -i "37i neutron_plugin_agent: \"openvswitch\" " /etc/kolla/globals.yml
sudo sed -i "38i enable_openstack_core: \"yes\" " /etc/kolla/globals.yml
sudo sed -i "39i enable_cinder: \"yes\" " /etc/kolla/globals.yml
sudo sed -i "40i enable_cinder_backup: \"no\" " /etc/kolla/globals.yml
sudo sed -i "41i enable_cinder_backend_lvm: \"yes\" " /etc/kolla/globals.yml
sudo sed -i "42i cinder_volume_group: \"cinder-volumes\" " /etc/kolla/globals.yml
sudo sed -i "43i enable_cinder_backend_iscsi: \"{{ enable_cinder_backend_lvm | bool }}\" " /etc/kolla/globals.yml
sudo sed -i "44i enable_nova: \"{{ enable_openstack_core | bool }}\" " /etc/kolla/globals.yml
sudo sed -i "45i nova_compute_virt_type:  \"qemu\" " /etc/kolla/globals.yml
# Add the OVS mappings
sudo echo "[ml2_type_flat]" >>  /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "flat_networks = physnet1,physnet2" >>  /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "[ovs]" >>  /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "bridge_mappings = physnet1:br-ex,physnet2:br-ex2" >>  /etc/kolla/config/neutron/ml2_conf.ini
# Ensure python docker module is imported
python3 -c "import docker"
