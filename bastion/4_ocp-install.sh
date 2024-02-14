#!/bin/bash

# Set the variables
INSTALL_HOME="/opt/install"
INSTALL_DIR=$INSTALL_HOME/ocp4_install
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
REGISTRY_TOKEN=$(cat $INSTALL_HOME/quay-install/registry_token.64)
SSH_KEY=$(cat $INSTALL_HOME/ocp4upi.pub)
PULL_SECRET="{\"auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"}}}"
CERT=$(cat $INSTALL_HOME/quay-install/quay-config/ssl.cert)


# Create the install directory
rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR

# Copy the install-config.yaml file to the install directory
cp install-config.yaml $INSTALL_DIR

# Change directory to the install directory
cd $INSTALL_DIR

# Edit the the install-config file
sed -i "s|CLUSTER_NAME|${CLUSTER_NAME}|g" install-config.yaml
sed -i "s|BASE_DOMAIN|${BASE_DOMAIN}|g" install-config.yaml
sed -i "s|PULL_SECRET|${PULL_SECRET}|g" install-config.yaml
sed -i "s|SSH_KEY|${SSH_KEY}|g" install-config.yaml
sed  's/^/  /' $INSTALL_HOME/quay-install/quay-config/ssl.cert >> install-config.yaml

# Backup install-config file
cp install-config.yaml $INSTALL_HOME

# Create the manifests
openshift-install create manifests --dir=.

# Remove the master and worker machineset manifests
rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml

# Edit the cluster-scheduler-02-config.yml file to set mastersSchedulable to false
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml

# Create the ignition configs
openshift-install create ignition-configs --dir=.

# Change the permissions of the ignition config files
chmod +r *.ign

# Copy the ignition config files to the utility node
rsync -av *.ign utility.$CLUSTER_NAME.$BASE_DOMAIN:/var/www/html/openshift4/ignitions/


# Create base64-encoded ignition files
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" *.ign
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" *.ign
base64 -w0 merge-master.ign > merge-master.64
base64 -w0 merge-worker.ign > merge-worker.64
base64 -w0 merge-bootstrap.ign > merge-bootstrap.64

# Wait for the bootstrap to complete
#openshift-install wait-for bootstrap-complete  --dir=. --log-level=debug

# Wait for the install to complete
#openshift-install wait-for install-complete  --dir=. --log-level=debug

# Approve the pending CSRs that are not yet approved
#oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
#oc get csr | grep node:
