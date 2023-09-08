#!/bin/bash

# Check if the script was called with an argument
if [ $# -eq 0 ]; then
  echo 'Error: No argument passed'
  echo 'Please pass the init password for the private registry'
  exit 1
fi

# Set the variables
TOKEN="$1"
OCP_RELEASE='4.10.66'
LOCAL_REGISTRY='registry.plz-vmware-sit-c01.nbe.ahly.bank:8443'
LOCAL_REPOSITORY=plz-vmware-sit-c01/openshift4
PRODUCT_REPO='openshift-release-dev'
RELEASE_NAME="ocp-release"
LOCAL_SECRET_JSON="${HOME}/pull-secret.json"
ARCHITECTURE=x86_64

# Log in to the registry as the init user
podman login -u init -p $TOKEN $LOCAL_REGISTRY 

# Get the pull secret
cat pull-secret | jq . > $LOCAL_SECRET_JSON

# Convert the pull secret to base64
echo -n "init:${TOKEN}" | base64 -w0

# Sleep 10 seconds to copy the secret
sleep 10

# Open the pull secret file in vim
vim $LOCAL_SECRET_JSON 

oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}

