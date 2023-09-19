#!/bin/bash

# Set the variables
OCP_RELEASE='4.10.66'
LOCAL_REGISTRY='registry.plz-vmware-sit-c01.nbe.ahly.bank:8443'
LOCAL_REPOSITORY=plz-vmware-sit-c01/openshift4
PRODUCT_REPO='openshift-release-dev'
RELEASE_NAME="ocp-release"
LOCAL_SECRET_JSON="${HOME}/pull-secret.json"
ARCHITECTURE=x86_64
REGISTRY_TOKEN=$(echo -n "init:${INIT_PASSWORD}" | base64 -w0)
LOCAL_REGISTRY_SECRET="auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"},"


# Log in to the registry as the init user
podman login -u init -p $INIT_PASSWORD $LOCAL_REGISTRY 



# Convert the pull secret to base64
echo -n "init:${INIT_PASSWORD}" | base64 -w0

sed "s|auths\":{|${LOCAL_REGISTRY_SECRET}|g" pull-secret > $LOCAL_SECRET_JSON

oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}

