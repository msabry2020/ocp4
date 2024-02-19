PULL_SECRET_HOME=/root/ocp4/bastion
BASE_DOMAIN='adcb.com.eg'
CLUSTER_NAME='cp4d'
NTP_SERVER_IP="10.11.31.199"
ALLOWED_NETWORK="10.11.31.0/24"
INSTALL_HOME=/adcb/install
INSTALL_DIR=$INSTALL_HOME/ocp4
####
packages='openssl podman jq wget'
OCP_RELEASE="4.12"
OCP_VERSION="4.12.30"
SSH_KEY_NAME="ocp4upi"
BASE_URL="https://mirror.openshift.com/pub/openshift-v4"
RHCOS_URL="$BASE_URL/dependencies/rhcos/$OCP_RELEASE/$OCP_VERSION"
REGISTRY="registry.$CLUSTER_NAME.$BASE_DOMAIN"
LOCAL_REGISTRY="$REGISTRY:8443"
LOCAL_REPOSITORY=openshift4
PRODUCT_REPO='openshift-release-dev'
RELEASE_NAME="ocp-release"
LOCAL_SECRET_JSON="$INSTALL_HOME/pull-secret.json"
ARCHITECTURE=x86_64
no_proxy=.$CLUSTER_NAME.$BASE_DOMAIN
