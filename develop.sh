#!/bin/bash
echo "Configuring kolla"
source kolla-config.sh
echo "Deploying kolla-single host"
source kolla-maker.sh
echo "Running post install"
source kolla-post-install.sh
