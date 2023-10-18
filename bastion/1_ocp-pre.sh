#!/bin/bash
set -x

# Set the variables
OCP_VERSION="4.12.9"
SSH_KEY_NAME="ocp4upi"

# Download the OpenShift tools
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

# Extract the OpenShift tools
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

# Download the OpenShift images
mkdir /tmp/images
openshift-install coreos print-stream-json | grep -Eo '"https.*(kernel-)\w+(\.img)?"' | grep x86 | xargs wget -O /tmp/images/rhcos-live-kernel-x86_64
openshift-install coreos print-stream-json | grep -Eo '"https.*(initramfs.)\w+(\.img)?"' | grep x86 | xargs wget -O /tmp/images/rhcos-live-initramfs.x86_64.img
openshift-install coreos print-stream-json | grep -Eo '"https.*(rootfs.)\w+(\.img)?"' | grep x86 | xargs wget -O /tmp/images/rhcos-live-rootfs.x86_64.img

# Copy the OpenShift images to the infra node
rsync -av /tmp/images infra:/var/www/html/openshift4/

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$SSH_KEY_NAME

