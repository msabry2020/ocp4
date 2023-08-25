wget https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz
tar xvf mirror-registry.tar.gz -C /usr/bin
firewall-cmd --add-port=8443/tcp --permanent; firewall-cmd --reload
mirror-registry install --quayHostname registry.cp4d.nbe.com.eg
cp ./quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/ 
update-ca-trust extract 
podman login -u init -p <token> registry.cp4d.nbe.com.eg:8443
cat pull-secret | jq . > pull-secret.json  
echo -n 'init:<token>' | base64 -w0 
vim pull-secret.json

export OCP_RELEASE='4.10.66'
export LOCAL_REGISTRY=registry.cp4d.nbe.com.eg:8443 
export LOCAL_REPOSITORY=cp4d/openshift4 
export PRODUCT_REPO='openshift-release-dev' 
export RELEASE_NAME="ocp-release" 
export LOCAL_SECRET_JSON='/root/config/registry/pull-secret.json' 
export ARCHITECTURE=x86_64 

oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} 
