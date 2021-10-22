#!/bin/bash
echo "Configuring and deploying kolla-single host"
source kolla-maker.sh
echo "Running post install"
source kolla-post-install.sh
