#!/bin/bash

# Set the variables
OCP_VERSION="4.10.66"
SSH_KEY_NAME="ocp4upi"

# Download the OpenShift tools
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz

# Extract the OpenShift tools
tar xvf openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

# Download the OpenShift images
mkdir images
openshift-install coreos print-stream-json | grep -Eo '"https.*(kernel-)\w+(\.img)?"' | grep x86 | xargs wget -O images/rhcos-live-kernel-x86_6
openshift-install coreos print-stream-json | grep -Eo '"https.*(initramfs.)\w+(\.img)?"' | grep x86 | xargs wget -O images/rhcos-live-initramfs.x86_64.img
openshift-install coreos print-stream-json | grep -Eo '"https.*(rootfs.)\w+(\.img)?"' | grep x86 | xargs wget -O images/rhcos-live-rootfs.x86_64.img

# Copy the OpenShift images to the infra node
rsync -av images infra:/var/www/html/openshift4/

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$SSH_KEY_NAME
