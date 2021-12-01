# Kolla upgrades

Upgrading a running environment is possible and easy.

1. Edit the existing /etc/kolla/globals.yml file on your deployment node (the node you used to deploy the previous version) and define your new version:

`openstack_release: "xena"` # Change the "xena" version to your desired alias or number

2. To upgrade to your version redeploy the environment with:

'kolla-ansible -i ~/multinode deploy'

3. Wait untill the deployment completes amd enjoy!
