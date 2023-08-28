## Configure NFS Storage ##
---------------------------
# NFS Host #
...........
yum -y install nfs-utils
mkdir /nfs
echo '/nfs *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0)' > /etc/exports
firewall-cmd --add-service nfs --permanent
firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --reload
systemctl enable --now nfs-server rpcbind
exportfs -ar
showmount -e


## Configure NFS Dynamic Storage Provisioner ##
---------------------------------------------
# Bastion Host #
...............
git clone https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/
cd nfs-subdir-external-provisioner
vim deploy/class.yaml 
sed -i s/'namespace: default'/'namespace: nfs-dynamic-namespace'/g deploy/rbac.yaml

podman pull registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
podman tag registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 registry.cp4d.nbe.com.eg:8443/init/nfs-subdir-external-provisioner:v4.0.2
podman login -u init -p Q78G9q1mNxP64Lti52h3uFEeayVZbHS0 registry.cp4d.nbe.com.eg:8443
podman push registry.cp4d.nbe.com.eg:8443/init/nfs-subdir-external-provisioner:v4.0.2

vim deploy/deployment.yaml

oc create namespace nfs-dynamic-namespace
oc create -f deploy/rbac.yaml

oc create role use-scc-hostmount-anyuid --verb=use --resource=scc --resource-name=hostmount-anyuid -n nfs-dynamic-namespace
oc project nfs-dynamic-namespace
oc adm policy add-role-to-user use-scc-hostmount-anyuid -z nfs-client-provisioner --role-namespace='nfs-dynamic-namespace'

oc create -f deploy/deployment.yaml
oc create -f deploy/class.yaml
oc create -f deploy/test-claim.yaml

podman pull busybox
podman tag docker.io/library/busybox:latest registry.cp4d.nbe.com.eg:8443/init/busybox:latest
podman login -u init -p Q78G9q1mNxP64Lti52h3uFEeayVZbHS0 registry.cp4d.nbe.com.eg:8443
podman push registry.cp4d.nbe.com.eg:8443/init/busybox:latest
oc create -f deploy/test-pod.yaml


podman pull docker.io/bitnami/nginx
podman tag docker.io/bitnami/nginx:latest registry.cp4d.nbe.com.eg:8443/init/nginx:latest
podman push registry.cp4d.nbe.com.eg:8443/init/nginx:latest
oc new-project nginx-test-project
oc new-app --insecure-registry=true --name nginx-test-app --image registry.cp4d.nbe.com.eg:8443/init/nginx:latest
oc expose svc/nginx-test-app
curl http://nginx-test-app-nginx-test-project.apps.cp4d.nbe.com.eg
