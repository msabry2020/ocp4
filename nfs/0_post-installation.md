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
cp /root/ocp4/nfs/*.yaml /root/nfs-subdir-external-provisioner/deploy/

podman pull registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
podman tag registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nfs-subdir-external-provisioner:v4.0.2
podman login -u init -p Ex76J13posk54tjze8mOwSVYC02Z9gGT registry.plz-vmware-sit-c01.nbe.ahly.bank:8443
podman push registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nfs-subdir-external-provisioner:v4.0.2

oc create namespace nfs-dynamic-namespace
oc create -f /root/nfs-subdir-external-provisioner/deploy/rbac.yaml
oc create role use-scc-hostmount-anyuid --verb=use --resource=scc --resource-name=hostmount-anyuid -n nfs-dynamic-namespace
oc project nfs-dynamic-namespace
oc adm policy add-role-to-user use-scc-hostmount-anyuid -z nfs-client-provisioner --role-namespace='nfs-dynamic-namespace'

oc create -f /root/nfs-subdir-external-provisioner/deploy/deployment.yaml
oc create -f /root/nfs-subdir-external-provisioner/deploy/class.yaml
oc create -f /root/nfs-subdir-external-provisioner/deploy/test-claim.yaml

podman pull busybox
podman tag docker.io/library/busybox:latest registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/busybox:latest
podman login -u init -p Q78G9q1mNxP64Lti52h3uFEeayVZbHS0 registry.plz-vmware-sit-c01.nbe.ahly.bank:8443
podman push registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/busybox:latest
oc create -f deploy/test-pod.yaml


podman pull docker.io/bitnami/nginx
podman tag docker.io/bitnami/nginx:latest registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
podman login -u init -p Ex76J13posk54tjze8mOwSVYC02Z9gGT registry.plz-vmware-sit-c01.nbe.ahly.bank:8443
podman push registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
oc new-project nginx-test-project
oc new-app --insecure-registry=true --name nginx-test-app --image registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
oc expose svc/nginx-test-app
curl http://nginx-test-app-nginx-test-project.apps.plz-vmware-sit-c01.nbe.ahly.bank
