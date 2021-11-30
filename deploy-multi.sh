#!/bin/bash
echo "Installing dependecies and configureing kolla"
source ~/kolla-fountain/kolla-shaker-multi.sh
echo "Depoloying multi host"
source ~/kolla-fountain/kolla-deploy-multi.sh
echo "Running post install"
source ~/kolla-post-multi.sh
