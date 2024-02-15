#!/bin/bash

source vars.sh
INIT_PASSWORD=$(cat $INSTALL_HOME/quay-install/init_password.txt)
REGISTRY_TOKEN=$(echo -n "init:$INIT_PASSWORD" | base64 -w0)
LOCAL_REGISTRY_SECRET="auths\":{\"registry.${CLUSTER_NAME}.${BASE_DOMAIN}:8443\":{\"auth\":\"${REGISTRY_TOKEN}\",\"email\":\"admin@${BASE_DOMAIN}\"},"

echo $REGISTRY_TOKEN > $INSTALL_HOME/quay-install/registry_token.64
set -x

export no_proxy=registry.$CLUSTER_NAME.$BASE_DOMAIN

sed "s|auths\":{|${LOCAL_REGISTRY_SECRET}|g" $INSTALL_HOME/pull-secret | jq . > $LOCAL_SECRET_JSON 

oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_VERSION}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}
