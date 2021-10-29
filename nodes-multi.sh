#!/bin/bash
echo "Prepping host"
source host-prep.sh
echo "Installing dependecies and configureing kolla"
source kolla-shaker-multi.sh
