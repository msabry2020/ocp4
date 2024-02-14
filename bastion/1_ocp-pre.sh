#!/bin/bash
set -x

# Set the variables
INSTALL_HOME="/opt/install"
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

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f $INSTALL_HOME/$SSH_KEY_NAME
