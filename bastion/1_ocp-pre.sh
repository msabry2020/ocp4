#!/bin/bash

set -x

source vars.sh
# Create INSTALL_HOME
mkdir -p $INSTALL_HOME

# Download the OpenShift tools
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

# Extract the OpenShift tools
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

# Generate the SSH key
ssh-keygen -t rsa -b 4096 -N '' -f $INSTALL_HOME/$SSH_KEY_NAME
