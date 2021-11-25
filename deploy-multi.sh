#!/bin/bash
echo "Prepping host"
source ~/kolla-fountain/host-prep.sh
echo "Installing dependecies and configureing kolla"
source ~/kolla-fountain/kolla-shaker-multi.sh
#echo "Configuring and deploying kolla-single host"
#source ~/kolla-fountain/kolla-maker.sh
echo "Depoloying multi host"
source ~/kolla-fountain/kolla-deploy-multi.sh
echo "Running post install"
source ~/kolla-fountain/kolla-post-install.sh
