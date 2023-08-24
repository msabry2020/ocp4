# Loging 
docker  login quay.io  --authfile=/root/private-image-registry/pull-secret.json
podman  login quay.io  --authfile=/root/private-image-registry/pull-secret.json
#podman  login cp.icr.io -u cp -p eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1ODMwNTczMzAsImp0aSI6IjIzZmJjMmU5YTcyYTQ1Mjc4NGM2NmM1OGM0NjA4NmU1In0.u0fXMaUS6F6cIVMVnUST-odZ88JG_agOaf89jC7b6oE
podman login registry.redhat.io -u user-name -p password-

mkdir -p /data/registry/{auth,certs,data}

openssl req -newkey rsa:4096 -nodes -sha256 \
-keyout /data/registry/certs/api.cp4d.nbe.com.eg.key -x509 -days 3650 \
-out /data/registry/certs/api.cp4d.nbe.com.eg.crt \
-subj "/C=US/ST=NorthCarolina/L=Raleigh/O=Red Hat/OU=Engineering/CN=api.cp4d.nbe.com.eg" \
-addext "subjectAltName = DNS:api.cp4d.nbe.com.eg"

cp /data/registry/certs/api.cp4d.nbe.com.eg.crt /etc/pki/ca-trust/source/anchors/

update-ca-trust

dnf -y install httpd-tools
htpasswd -bBc /data/registry/auth/htpasswd registry redhat12345678

date | md5sum

dnf -y install podman

podman create --name ocp-registry --net host -p 5000:5000 \
   -v /data/registry/data:/var/lib/registry:z -v /data/registry/auth:/auth:z \
   -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
   -e "REGISTRY_HTTP_SECRET=848afb52c4dc67a9504ae916afa462f0" \
   -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /data/registry/certs:/certs:z \
   -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/api.cp4d.nbe.com.eg.crt \
   -e REGISTRY_HTTP_TLS_KEY=/certs/api.cp4d.nbe.com.eg.key docker.io/library/registry:2.6
   
cat /etc/systemd/system/ocp-registry.service

[Unit]
Description=OCP Registry
[Service]
Restart=always
ExecStart=/usr/bin/podman start -a ocp-registry
ExecStop=/usr/bin/podman stop -t 10 ocp-registry
[Install]
WantedBy=network-online.target

curl -u 'registry:redhat12345678' https://api.cp4d.nbe.com.eg:5000/v2/_catalog%7Cjq
curl -u 'registry:redhat12345678' https://api.cp4d.nbe.com.eg:5000/v2/ocp4/openshift4/tags/list |jq
 
export OCP_RELEASE=4.12.24
export LOCAL_REGISTRY='api.cp4d.nbe.com.eg:5000'
export LOCAL_REPOSITORY='ocp4/openshift4'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/root/private-image-registry/pull-secret.json'
export RELEASE_NAME="ocp-release"
export ARCHITECTURE=x86_64
export REMOVABLE_MEDIA_PATH='/data/registry'
export REG_CREDS=/root/private-image-registry/pull-secret.json

1- Mirror OCP imgaes 16GB:
----------------------
nohup oc adm release mirror -a ${LOCAL_SECRET_JSON} --insecure=true --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
--to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} &

2- Mirror redhat-operators more than 400 GB:
-----------------------------------------
oc adm catalog mirror registry.redhat.io/redhat/redhat-operator-index:v4.12 api.cp4d.nbe.com.eg:5000/shadyprivate -a ${REG_CREDS} \
--insecure --index-filter-by-os='linux/amd64' 

3-Mirroring Data Foundation images deployed on OpenShift® Container Platform version 4.12
https://www.ibm.com/docs/en/storage-fusion/2.5?topic=myier-mirroring-data-foundation-images-deployed-openshift-container-platform-version-412

export LOCAL_SECRET_JSON='/root/private-image-registry/pull-secret.json'
export LOCAL_ISF_REGISTRY="api.cp4d.nbe.com.eg:5000"
export LOCAL_ISF_REPOSITORY="mirror"
export TARGET_PATH="$LOCAL_ISF_REGISTRY/$LOCAL_ISF_REPOSITORY"
podman login $LOCAL_ISF_REGISTRY -u registry -p redhat12345678
podman login registry.redhat.io -u user-name -p password-
