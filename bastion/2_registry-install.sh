#!/bin/bash
set -x

# Set the variables
INSTALL_HOME="/opt/install"
REGISTRY="registry.ocp4.lab.local"
export INIT_PASSWORD=$(openssl rand --base64 20)

# Download the mirror registry binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz -P $INSTALL_HOME

# Extract the binary to /usr/bin
tar xvf $INSTALL_HOME/mirror-registry.tar.gz -C /usr/bin

# Add the port 8443 to the firewall
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --reload

# Install the mirror registry
mirror-registry install --quayHostname $REGISTRY --quayRoot $INSTALL_HOME/quay-install --initPassword $INIT_PASSWORD

# Copy the root CA certificate to the CA trust store
cp $INSTALL_HOME/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/

# Update the CA trust store
update-ca-trust extract

echo $INIT_PASSWORD > $INSTALL_HOME/quay-install/init_password.txt
