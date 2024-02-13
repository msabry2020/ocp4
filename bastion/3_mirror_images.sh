#!/bin/bash

set -x
# Set the variables
INSTALL_HOME='/opt/install'
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
INIT_PASSWORD=$(cat $INSTALL_HOME/quay-install/init_password.txt)
OCP_RELEASE='4.12.30'
LOCAL_REGISTRY='registry.ocp4.lab.local:8443'
LOCAL_REPOSITORY=openshift4
PRODUCT_REPO='openshift-release-dev'
RELEASE_NAME="ocp-release"
LOCAL_SECRET_JSON="$INSTALL_HOME/pull-secret.json"
ARCHITECTURE=x86_64
REGISTRY_TOKEN=$(echo -n "init:${INIT_PASSWORD}" | base64 -w0)
LOCAL_REGISTRY_SECRET="auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"},"

echo $REGISTRY_TOKEN > $INSTALL_HOME/quay-install/registry_token.64

# Log in to the registry as the init user
podman login -u init -p $INIT_PASSWORD $LOCAL_REGISTRY 

sed "s|auths\":{|${LOCAL_REGISTRY_SECRET}|g" $INSTALL_HOME/pull-secret | jq . > $LOCAL_SECRET_JSON 

oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}
