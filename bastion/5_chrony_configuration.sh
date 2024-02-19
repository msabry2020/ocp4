#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

echo -e "Download the Butane binary\n"
wget https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-amd64 -P $INSTALL_HOME

echo -e "Copy the binary to /usr/bin\n"
chmod u+x $INSTALL_HOME/butane-amd64
cp $INSTALL_HOME/butane-amd64 /usr/bin/butane

echo -e "Set the NTP server IP in the butane files"
sed -i "s/NTP_SERVER_IP/${NTP_SERVER_IP}/g" 99-master-chrony.bu
sed -i "s/NTP_SERVER_IP/${NTP_SERVER_IP}/g" 99-worker-chrony.bu

echo -e "Copy butane configs to the installation directory\n"
cp 99-master-chrony.bu $INSTALL_DIR/
cp 99-worker-chrony.bu $INSTALL_DIR/

echo -e "Generate MachineConfig obhect files to contain the configuration for nodes\n"
/usr/bin/butane $INSTALL_DIR/99-master-chrony.bu -o $INSTALL_DIR/99-master-chrony.yaml
/usr/bin/butane $INSTALL_DIR/99-worker-chrony.bu -o $INSTALL_DIR/99-worker-chrony.yaml

echo -e "Apply time configurations\n"
export KUBECONFIG=$INSTALL_DIR/auth/kubeconfig
oc apply -f $INSTALL_DIR/99-master-chrony.yaml
oc apply -f $INSTALL_DIR/99-worker-chrony.yaml

echo -e "Check for each server if NTP source is as expected (run this command from Bastion VM)\n"
sleep 30
vms=("control1" "control2" "control3" "infra1" "infra2" "infra3" "worker1" "worker2" "worker3")
for VM_NAME in "${vms[@]}"
do
    ssh -i $INSTALL_HOME/ocp4upi core@$VM_NAME.$CLUSTER_NAME.$BASE_DOMAIN echo -e "Time on $VM_NAME sync with: " ; chronyc sources
    sleep 3
    echo -e "\n\n"
done
