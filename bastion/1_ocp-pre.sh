#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

echo -e "Create INSTALL_HOME\n"
mkdir -p $INSTALL_HOME

echo -e "Download the OpenShift tools\n"
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

echo -e "Extract the OpenShift tools\n"
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

echo -e "Generate the SSH key\n"
ssh-keygen -t rsa -b 4096 -N '' -f $INSTALL_HOME/$SSH_KEY_NAME
