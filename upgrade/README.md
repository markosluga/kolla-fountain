# Kolla upgrades

Upgrading a running environment is possible and easy.

1. Edit the globals.yml file and select your version:

`openstack_release: "xena"` # Change the "xena" version to your desired alias or number

2. To upgrade to your version redeploy the environment with:

'kolla-ansible -i ~/multinode deploy'

3. Wait untill the deployment completes amd enjoy!
