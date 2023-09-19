#!/bin/bash
set -x

# Set the variables
REGISTRY="registry.plz-vmware-sit-c01.nbe.ahly.bank"
INIT_PASSWORD=$(openssl rand --base64 20)
# Download the mirror registry binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz -P /tmp

# Extract the binary to /usr/bin
tar xvf /tmp/mirror-registry.tar.gz -C /usr/bin

# Add the port 8443 to the firewall
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --reload

# Install the mirror registry
cd ~
mirror-registry install --quayHostname $REGISTRY --initPassword $INIT_PASSWORD

# Copy the root CA certificate to the CA trust store
cp quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/

# Update the CA trust store
update-ca-trust extract

echo $INIT_PASSWORD

./3_mirror_images.sh
