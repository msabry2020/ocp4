i#!/bin/bash

# Set the variables
INSTALL_DIR="${HOME}/install"

# Create the install directory
mkdir $INSTALL_DIR

# Copy the install-config.yaml file to the install directory
cp bastion/install-config.yaml $INSTALL_DIR

# Change directory to the install directory
cd $INSTALL_DIR

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

# Copy the ignition config files to the infra node
rsync -av *.ign infra:/var/www/html/openshift4/ignitions/

# Wait for the bootstrap to complete
openshift-install wait-for bootstrap-complete  --dir=. --log-level=debug

# Wait for the install to complete
openshift-install wait-for install-complete  --dir=. --log-level=debug

# Approve the pending CSRs that are not yet approved
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
