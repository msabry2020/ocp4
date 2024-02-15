#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

echo -e "initialize install-config variables\n"
REGISTRY_TOKEN=$(cat $INSTALL_HOME/quay-install/registry_token.64)
SSH_KEY=$(cat $INSTALL_HOME/ocp4upi.pub)
PULL_SECRET="{\"auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"}}}"
CERT=$(cat $INSTALL_HOME/quay-install/quay-config/ssl.cert)

echo -e "Create the install directory\n"
rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR

echo -e "Copy the install-config.yaml file to the install directory\n"
cp install-config.yaml $INSTALL_DIR

echo -e "Change directory to the install directory\n"
cd $INSTALL_DIR

echo -e "Edit the the install-config file\n"
sed -i "s|CLUSTER_NAME|${CLUSTER_NAME}|g" install-config.yaml
sed -i "s|BASE_DOMAIN|${BASE_DOMAIN}|g" install-config.yaml
sed -i "s|PULL_SECRET|${PULL_SECRET}|g" install-config.yaml
sed -i "s|SSH_KEY|${SSH_KEY}|g" install-config.yaml
sed  's/^/  /' $INSTALL_HOME/quay-install/quay-config/ssl.cert >> install-config.yaml

echo -e "Backup install-config file\n"
cp install-config.yaml $INSTALL_HOME

echo -e "Create the manifests\n"
openshift-install create manifests --dir=.

echo -e "Remove the master and worker machineset manifests\n"
rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml

echo -e "Edit the cluster-scheduler-02-config.yml file to set mastersSchedulable to false\n"
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml

echo -e "Enable verbose output for debugging\n"
set -x

echo -e "Create the ignition configs\n"
openshift-install create ignition-configs --dir=.
set +x

echo -e "Change the permissions of the ignition config files\n"
chmod +r *.ign

echo -e "Copy the ignition config files to the utility node\n"
rsync -av *.ign utility.$CLUSTER_NAME.$BASE_DOMAIN:/var/www/html/openshift4/ignitions/

echo -e "Create base64-encoded ignition files\n"
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
