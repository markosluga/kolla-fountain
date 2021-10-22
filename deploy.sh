#!/bin/bash
echo "Prepping host"
source host-prep.sh
echo "Installing dependecies and configureing kolla"
source kolla-shaker.sh
echo "Configuring and deploying kolla-single host"
source kolla-maker.sh
echo "Running post install"
source kolla-post-install.sh

