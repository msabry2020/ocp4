#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

echo -e "Create INSTALL_HOME\n"
mkdir -p $INSTALL_HOME

echo -e "Download the OpenShift tools\n"
wget -c --no-check-certificate $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-client-linux-$OCP_VERSION.tar.gz -P /tmp
wget -c --no-check-certificate $BASE_URL/x86_64/clients/ocp/$OCP_VERSION/openshift-install-linux-$OCP_VERSION.tar.gz -P /tmp

echo -e "Extract the OpenShift tools\n"
tar xvf /tmp/openshift-client-linux-$OCP_VERSION.tar.gz -C /usr/bin/
tar xvf /tmp/openshift-install-linux-$OCP_VERSION.tar.gz -C /usr/bin/

echo -e "Download the OpenShift images\n"
mkdir /tmp/images
wget $RHCOS_URL/rhcos-live-kernel-x86_64 -O /tmp/images/rhcos-live-kernel-x86_64
wget $RHCOS_URL/rhcos-live-initramfs.x86_64.img -O /tmp/images/rhcos-live-initramfs.x86_64.img
wget $RHCOS_URL/rhcos-live-rootfs.x86_64.img -O /tmp/images/rhcos-live-rootfs.x86_64.img

echo -e "Copy the OpenShift images to the infra node\n"
rsync -av /tmp/images root@$UTIL_IP:/var/www/html/openshift4/

echo -e "Generate the SSH key\n"
ssh-keygen -t rsa -b 4096 -N '' -f $INSTALL_HOME/$SSH_KEY_NAME
