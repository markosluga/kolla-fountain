#!/bin/bash
echo "Prepping host"
source ~/kolla-fountain/host-prep.sh
echo "Installing dependecies and configureing kolla"
source ~/kolla-fountain/kolla-shaker-single.sh
echo "Depoloying single host"
source ~/kolla-fountain/kolla-deploy-single.sh
echo "Running post install"
source ~/kolla-fountain/kolla-post-install.sh

