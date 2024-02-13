#!/bin/bash

set -x

# Set the variables
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
INSTALL_HOME="/opt/install"
INSTALL_DIR=$INSTALL_HOME/ocp4_install
NTP_SERVER_IP="10.11.31.199"
ALLOWED_NETWORK="10.11.31.0/24"

# Set NTP server IP on Bastion VM
sed -i "s|pool 2.rhel.pool.ntp.org iburst|server ${NTP_SERVER_IP}|g" /etc/chrony.conf
sed -i "s|#allow 192.168.0.0/16|allow ${ALLOWED_NETWORK}|g" /etc/chrony.conf

# Restart Chrony service
systemctl restart chronyd.service

# Check current Chrony sources list
chronyc sources

# Download the Butane binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-amd64 -P $INSTALL_HOME

# Copy the binary to /usr/bin
chmod u+x $INSTALL_HOME/butane-amd64
cp $INSTALL_HOME/butane-amd64 /usr/bin/butane

# Copy butane configs to the installation directory
cp 99-master-chrony.bu $INSTALL_DIR/
cp 99-worker-chrony.bu $INSTALL_DIR/

# Generate MachineConfig obhect files to contain the configuration for nodes
/usr/bin/butane $INSTALL_DIR/99-master-chrony.bu -o $INSTALL_DIR/99-master-chrony.yaml
/usr/bin/butane $INSTALL_DIR/99-worker-chrony.bu -o $INSTALL_DIR/99-worker-chrony.yaml

# Apply time configurations
export KUBECONFIG=$INSTALL_DIR/auth/kubeconfig
oc apply -f $INSTALL_DIR/99-master-chrony.yaml
oc apply -f $INSTALL_DIR/99-worker-chrony.yaml

# Check for each server if NTP source is as expected (run this command from Bastion VM)
sleep 30
vms=("control1" "control2" "control3" "infra1" "infra2" "infra3" "worker1" "worker2" "worker3")
for VM_NAME in "${vms[@]}"
do
    ssh -i $INSTALL_HOME/ocp4upi core@$VM_NAME.$CLUSTER_NAME.$BASE_DOMAIN echo "Time on $VM_NAME sync with: " ; chronyc sources
    sleep 3
    echo -e "\n\n"
done
