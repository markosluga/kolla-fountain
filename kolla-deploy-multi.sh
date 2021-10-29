#!/bin/bash
echo "Prepping host"
source host-prep.sh
echo "Installing dependecies and configureing kolla"
source kolla-shaker-multi.sh
echo "Configuring and deploying kolla-single host"
source kolla-maker.sh
echo "Depoloying single host"
source kolla-deploy-multi.sh
echo "Running post install"
source kolla-post-install.sh
