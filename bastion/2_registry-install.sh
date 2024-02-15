#!/bin/bash

echo "Load variables from vars file\n"
source vars.sh

echo "Create the init password\n"
INIT_PASSWORD=$(openssl rand --base64 20)

echo "Download the mirror registry binary\n"
wget https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz -P $INSTALL_HOME

echo "Extract the binary to /usr/bin\n"
tar xvf $INSTALL_HOME/mirror-registry.tar.gz -C /usr/bin

echo "Add the port 8443 to the firewall\n"
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --reload

echo "Enable verbose output for debugging\n"
set -x

echo "Install the mirror registry\n"
mirror-registry install --quayHostname $REGISTRY --quayRoot $INSTALL_HOME/quay-install --initPassword $INIT_PASSWORD
set +x

echo "Copy the root CA certificate to the CA trust store\n"
cp $INSTALL_HOME/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/

echo "Update the CA trust store\n"
update-ca-trust extract

echo "Save the Init Password\n"
echo $INIT_PASSWORD > $INSTALL_HOME/quay-install/init_password.txt
