# Make the kolla user
sudo adduser kolla
sudo usermod -aG sudo kolla
# Make kolla user a sudoer
sudo sed -i -e '$akolla ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
