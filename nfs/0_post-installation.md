## Configure NFS Storage ##
---------------------------
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


## Create Nginx Test App ##
-------------------------
podman pull docker.io/bitnami/nginx
podman tag docker.io/bitnami/nginx:latest registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
podman login -u init -p Ex76J13posk54tjze8mOwSVYC02Z9gGT registry.plz-vmware-sit-c01.nbe.ahly.bank:8443
podman push registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
oc new-project nginx-test-project
oc new-app --insecure-registry=true --name nginx-test-app --image registry.plz-vmware-sit-c01.nbe.ahly.bank:8443/init/nginx:latest
oc expose svc/nginx-test-app
curl http://nginx-test-app-nginx-test-project.apps.plz-vmware-sit-c01.nbe.ahly.bank

## Configure Identity Provider ##
-------------------------------
yum -y install htppd-tools
htpasswd -c -B -b /tmp/htpasswd admin redhat
oc create secret generic localusers --from-file htpasswd=/tmp/htpasswd -n openshift-config
oc adm policy add-cluster-role-to-user cluster-admin admin
oc edit oauth/cluster
  identityProviders:
    - htpasswd:
        fileData:
          name: localusers
      mappingMethod: claim
      name: myusers
      type: HTPasswd

watch oc get pods -n openshift-authentication
oc login -u admin -p redhat https://api.plz-vmware-sit-c01.nbe.ahly.bank:6443
