#!/bin/bash
set -x

# Set the variables
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
OCP_RELEASE="4.12"
OCP_VERSION="4.12.30"
SSH_KEY_NAME="ocp4upi"
BASE_URL="https://mirror.openshift.com/pub/openshift-v4"
RHCOS_URL="$BASE_URL/dependencies/rhcos/$OCP_RELEASE/$OCP_VERSION"

# Download the OpenShift tools
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

# Extract the OpenShift tools
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

# Download the OpenShift images
mkdir /tmp/images
wget $RHCOS_URL/rhcos-live-kernel-x86_64 -O /tmp/images/rhcos-live-kernel-x86_64
wget $RHCOS_URL/rhcos-live-initramfs.x86_64.img -O /tmp/images/rhcos-live-initramfs.x86_64.img
wget $RHCOS_URL/rhcos-live-rootfs.x86_64.img -O /tmp/images/rhcos-live-rootfs.x86_64.img

# Copy the OpenShift images to the infra node
rsync -av /tmp/images utility.$CLUSTER_NAME.$BASE_DOMAIN:/var/www/html/openshift4/

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$SSH_KEY_NAME
