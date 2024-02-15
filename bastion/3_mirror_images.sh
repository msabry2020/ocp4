#!/bin/bash

echo "Load variables from vars file\n"
source vars.sh

echo "Retrieve the init password\n"
INIT_PASSWORD=$(cat $INSTALL_HOME/quay-install/init_password.txt)

echo "Encode the init password and create registry token\n"
REGISTRY_TOKEN=$(echo -n "init:$INIT_PASSWORD" | base64 -w0)

echo "Define local registry secret in JSON format\n"
LOCAL_REGISTRY_SECRET="auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"},"

echo "Save the registry token to a file\n"
echo $REGISTRY_TOKEN > $INSTALL_HOME/quay-install/registry_token.64

echo "Modify pull secret JSON to include local registry authentication\n"
sed "s|auths\":{|${LOCAL_REGISTRY_SECRET}|g" $INSTALL_HOME/pull-secret | jq . > $LOCAL_SECRET_JSON 

echo "Enable verbose output for debugging\n"
set -x

echo "Mirror OpenShift release images to the local registry\n"
oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_VERSION}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}
