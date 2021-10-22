#!/bin/bash
echo "Prepping host"
source host-prep.sh
echo "Installing dependecies and configureing kolla"
source kolla-shaker.sh
echo "Configuring kolla"
source kolla-config.sh
echo "Deploying kolla-single host"
source kolla-maker.sh
echo "Running post install"
source kolla-post-install.sh
echo "Process completed successfully!"
echo "OpenStack deployed at 172.25.216.200"
