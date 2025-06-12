Recovery plane (master01)
=========================
[core@master01 ~]$ sudo -E /usr/local/bin/cluster-restore.sh /home/core/assets/backup
0eeeca58c6b3b70ca5e6f66d42c941c4d10bdabfb7f9deb49be5aa352007184f
etcdctl version: 3.5.16
API version: 3.5
{"hash":3582676845,"revision":38858,"totalKey":11627,"totalSize":89231360}
...stopping kube-apiserver-pod.yaml
...stopping kube-controller-manager-pod.yaml
...stopping kube-scheduler-pod.yaml
Waiting for container kube-controller-manager to stop
.complete
Waiting for container kube-apiserver to stop
.................................................................................................................................complete
Waiting for container kube-scheduler to stop
complete
...stopping etcd-pod.yaml
Waiting for container etcd to stop
......complete
Waiting for container etcdctl to stop
.............................complete
Waiting for container etcd-metrics to stop
complete
Waiting for container etcd-readyz to stop
complete
Moving etcd data-dir /var/lib/etcd/member to /var/lib/etcd-backup
starting restore-etcd static pod
starting kube-apiserver-pod.yaml
static-pod-resources/kube-apiserver-pod-6/kube-apiserver-pod.yaml
starting kube-controller-manager-pod.yaml
static-pod-resources/kube-controller-manager-pod-7/kube-controller-manager-pod.yaml
starting kube-scheduler-pod.yaml
static-pod-resources/kube-scheduler-pod-7/kube-scheduler-pod.yaml





master02/3
==========
[lab@utility install]$ ssh -i ocp4upi core@master03.ocp4
The authenticity of host 'master03.ocp4 (192.168.50.12)' can't be established.
ECDSA key fingerprint is SHA256:J3PMdhgWVyWFcuaT5DqrqRZ+GkTswGZT2wZww6owpvo.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'master03.ocp4,192.168.50.12' (ECDSA) to the list of known hosts.
Red Hat Enterprise Linux CoreOS 417.94.202502111408-0
  Part of OpenShift 4.17, RHCOS is a Kubernetes-native operating system
  managed by the Machine Config Operator (`clusteroperator/machine-config`).

WARNING: Direct SSH access to machines is not recommended; instead,
make configuration changes via `machineconfig` objects:
  https://docs.openshift.com/container-platform/4.17/architecture/architecture-rhcos.html

---
[core@master03 ~]$ 
[core@master03 ~]$ sudo mv -v /etc/kubernetes/manifests/etcd-pod.yaml /tmp
copied '/etc/kubernetes/manifests/etcd-pod.yaml' -> '/tmp/etcd-pod.yaml'
removed '/etc/kubernetes/manifests/etcd-pod.yaml'
[core@master03 ~]$ watch 'sudo crictl ps | grep etcd | egrep -v "operator|etcd-guard"'

[core@master03 ~]$ sudo mv -v /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp
copied '/etc/kubernetes/manifests/kube-apiserver-pod.yaml' -> '/tmp/kube-apiserver-pod.yaml'
removed '/etc/kubernetes/manifests/kube-apiserver-pod.yaml'
[core@master03 ~]$ watch 'sudo crictl ps | grep kube-apiserver | egrep -v "operator|guard"'

[core@master03 ~]$ sudo mv -v /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp
mv: cannot stat '/etc/kubernetes/manifests/kube-apiserver-pod.yaml': No such file or directory
[core@master03 ~]$ watch 'sudo crictl ps | grep kube-apiserver | egrep -v "operator|guard"'

[core@master03 ~]$ sudo mv -v /etc/kubernetes/manifests/kube-controller-manager-pod.yaml /tmp
copied '/etc/kubernetes/manifests/kube-controller-manager-pod.yaml' -> '/tmp/kube-controller-manager-pod.yaml'
removed '/etc/kubernetes/manifests/kube-controller-manager-pod.yaml'
[core@master03 ~]$ watch 'sudo crictl ps | grep kube-controller-manager | egrep -v "operator|guard"'

[core@master03 ~]$ sudo mv -v /etc/kubernetes/manifests/kube-scheduler-pod.yaml /tmp
copied '/etc/kubernetes/manifests/kube-scheduler-pod.yaml' -> '/tmp/kube-scheduler-pod.yaml'
removed '/etc/kubernetes/manifests/kube-scheduler-pod.yaml'
[core@master03 ~]$ watch 'sudo crictl ps | grep kube-scheduler | egrep -v "operator|guard"'


