#!/bin/bash

set -x

# Set the variables
NBE_HOME="/nbe"
NTP_SERVER_IP="172.16.0.9"
ALLOWED_NETWORK="10.50.162.0/24"

# Set NTP server IP on Bastion VM
sed -i "s|pool 2.rhel.pool.ntp.org iburst|server ${NTP_SERVER_IP}|g" /etc/chrony.conf
sed -i "s|#allow 192.168.0.0/16|allow ${ALLOWED_NETWORK}|g" /etc/chrony.conf

# Restart Chrony service
systemctl restart chronyd.service

# Check current Chrony sources list
chronyc sources

# Download the Butane binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-amd64 -P $NBE_HOME

# Copy the binary to /usr/bin
chmod u+x $NBE_HOME/butane-amd64
mv $NBE_HOME/butane-amd64 /usr/bin/butane

# Copy butane configs to the installation directory
cp 99-master-chrony.bu $NBE_HOME/install/
cp 99-worker-chrony.bu $NBE_HOME/install/

# Generate MachineConfig obhect files to contain the configuration for nodes
/usr/bin/butane $NBE_HOME/install/99-master-chrony.bu -o $NBE_HOME/install/99-master-chrony.yaml
/usr/bin/butane $NBE_HOME/install/99-worker-chrony.bu -o $NBE_HOME/install/99-worker-chrony.yaml

# Apply time configurations
export KUBECONFIG=$NBE_HOME/install/auth/kubeconfig
oc apply -f $NBE_HOME/install/99-master-chrony.yaml
oc apply -f $NBE_HOME/install/99-worker-chrony.yaml

# Check for each server if NTP source is as expected (run this command from Bastion VM)
sleep 30
vms=("master01" "master02" "master03" "worker01" "worker02" "worker03")
for VM_NAME in "${vms[@]}"
do
    ssh -i /nbe/ocp4upi core@$VM_NAME.plz-vmware-sit-c01.nbe.ahly.bank echo "Time on $VM_NAME sync with: " ; chronyc sources
    sleep 3
    echo -e "\n\n"
done
