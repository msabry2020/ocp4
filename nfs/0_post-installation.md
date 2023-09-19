#!/bin/bash

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
