# Ensure python docker module is imported
python3 -c "import docker"
# Deploy Kolla
kolla-ansible -i ~/all-in-one deploy
