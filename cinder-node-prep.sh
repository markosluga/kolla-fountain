# Create an empty logical volume group for cinder
sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb
