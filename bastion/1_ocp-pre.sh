#!/bin/bash
set -x

# Set the variables
NBE_HOME="/nbe"
OCP_VERSION="4.10.66"
SSH_KEY_NAME="ocp4upi"

# Download the OpenShift tools
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

# Extract the OpenShift tools
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$SSH_KEY_NAME
