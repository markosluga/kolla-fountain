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
sed -i '33s/$/ become=true/' ~/multinode
sed -i '5,7d' ~/multinode
sed -i '5ikolla[02:03] ansible_user=kolla ansible_become=true' ~/multinode
sed -i '13,14d' ~/multinode
sed -i '13ikolla4' ~/multinode
sed -i '16d' ~/multinode
sed -i '16ikolla01' ~/multinode
sed -i '19d' ~/multinode
sed -i '19ikolla[02:03]' ~/multinode
sed -i '27d' ~/multinode
sed -i '27ikolla[01:04]' ~/multinode
# Ensure python docker module is imported
python3 -c "import docker"
