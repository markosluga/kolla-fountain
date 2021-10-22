#!/bin/bash

# Configure kolla /etc/kolla/globals.yml
sudo sed -i "27i config_strategy: \"COPY_ALWAYS\" " /etc/kolla/globals.yml
sudo sed -i "28i kolla_base_distro: \"ubuntu\" " /etc/kolla/globals.yml
sudo sed -i "29i kolla_install_type: \"binary\" " /etc/kolla/globals.yml
sudo sed -i "30i openstack_release: \"wallaby\" " /etc/kolla/globals.yml
sudo sed -i "31i kolla_internal_vip_address: \"172.20.208.200\" " /etc/kolla/globals.yml
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
sudo sed -i "46i enable_neutron_provider_networks: \"yes\" " /etc/kolla/globals.yml
sudo sed -i "47i enable_neutron_port_forwarding: \"yes\" " /etc/kolla/globals.yml
sudo sed -i "48i enable_openvswitch: \"yes\" " /etc/kolla/globals.yml 

# Add the OVS config to /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "[ml2_type_flat]" >>  /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "flat_networks = physnet1,physnet2" >>  /etc/kolla/config/neutron/ml2_conf.ini
#ml2
sudo echo "[ovs]" >> /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "tunnel_bridge = br-tun" >> /etc/kolla/config/neutron/ml2_conf.inii
sudo echo "int_peer_patch_port = patch-tun" >> /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "tun_peer_patch_port = patch-int" >> /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "bridge_mappings = physnet1:br-ex,physnet2:br-ex2" >> /etc/kolla/config/neutron/ml2_conf.ini
sudo echo "use_veth_interconnection = false" >> /etc/kolla/config/neutron/ml2_conf.ini
#agent
#sudo echo "[ovs]" >> /etc/kolla/config/neutron/openvswitch_agent.ini
#sudo echo "tunnel_bridge = br-tun" >> /etc/kolla/config/neutron/openvswitch_agent.ini
#sudo echo "int_peer_patch_port = patch-tun" >> /etc/kolla/config/neutron/openvswitch_agent.ini
#sudo echo "tun_peer_patch_port = patch-int" >> /etc/kolla/config/neutron/openvswitch_agent.ini
#sudo echo "bridge_mappings = physnet1:brex,physnet2:brex2" >> /etc/kolla/config/neutron/openvswitch_agent.ini
#sudo echo "use_veth_interconnection = false" >> /etc/kolla/config/neutron/openvswitch_agent.ini

# Deploy Kolla
kolla-ansible -i ~/all-in-one deploy
