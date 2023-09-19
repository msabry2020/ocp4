#!/bin/bash
set -x

# Set the variables
REGISTRY="registry.plz-vmware-sit-c01.nbe.ahly.bank"
export INIT_PASSWORD=$(openssl rand --base64 20)
NBE_HOME="/nbe"

# Download the mirror registry binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz -P /tmp

# Extract the binary to /usr/bin
tar xvf /tmp/mirror-registry.tar.gz -C /usr/bin

# Add the port 8443 to the firewall
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --reload

# Install the mirror registry
mirror-registry install --quayHostname $REGISTRY --quayRoot $NBE_HOME/quay-install --initPassword $INIT_PASSWORD

# Copy the root CA certificate to the CA trust store
cp $NBE_HOME/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/

# Update the CA trust store
update-ca-trust extract

echo $INIT_PASSWORD > init_password.txt

cd $NBE_HOME/ocp4/bastion
./3_mirror_images.sh
