#!/bin/bash
set -x
echo '# Set the variables #'
BASE_DOMAIN='nbe.ahly.bank'
CLUSTER_NAME='plz-vmware-sit-c01'
REVERSE_SUBNET='162.50.10'
INFRA_IP="10.50.162.163"
BASTION_IP="10.50.162.152"
STORAGE_IP="10.50.162.162"
WAS_IP="10.50.162.161"
BOOTSTRAP_IP="10.50.162.154"
MASTER01_IP="10.50.162.155"
MASTER02_IP="10.50.162.156"
MASTER03_IP="10.50.162.157"
WORKER01_IP="10.50.162.158"
WORKER02_IP="10.50.162.159"
WORKER03_IP="10.50.162.160"
echo "-----------------------------------"
set +x

echo '# DNS Configuration #'
set -x
## named.conf ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" named.conf 
sed -i "s/REVERSE_SUBNET/${REVERSE_SUBNET}/g" named.conf 

## forward.zone ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" forward.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" forward.zone
sed -i "s/INFRA_IP/${INFRA_IP}/g" forward.zone
sed -i "s/BASTION_IP/${BASTION_IP}/g" forward.zone
sed -i "s/STORAGE_IP/${STORAGE_IP}/g" forward.zone
sed -i "s/WAS_IP/${WAS_IP}/g" forward.zone
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" forward.zone
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" forward.zone
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" forward.zone
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" forward.zone
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" forward.zone
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" forward.zone
sed -i "s/WORKER03_IP/${WORKER03_IP}/g" forward.zone

## reverse.zone ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" reverse.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" reverse.zone
sed -i "s/INFRA/$(echo $INFRA_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BASTION/$(echo $BASTION_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/STORAGE/$(echo $STORAGE_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WAS/$(echo $WAS_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BOOTSTRAP/$(echo $BOOTSTRAP_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER01/$(echo $MASTER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER02/$(echo $MASTER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER03/$(echo $MASTER03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER01/$(echo $WORKER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER02/$(echo $WORKER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER03/$(echo $WORKER03_IP | awk -F. '{print $4}')/g" reverse.zone

cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone
set +x
sleep 5
echo "-----------------------------------"


echo '# HAProxy Configuration #'
set -x
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" haproxy.cfg
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" haproxy.cfg
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" haproxy.cfg
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" haproxy.cfg
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" haproxy.cfg
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" haproxy.cfg
sed -i "s/WORKER03_IP/${WORKER03_IP}/g" haproxy.cfg

cp haproxy.cfg /etc/haproxy/haproxy.cfg 
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1
set +x
sleep 5
echo "-----------------------------------"

echo '# HTTP Server Configuration #'
set -x
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4/ignitions
restorecon -Rv /var/www/html/openshift4
set +x
sleep 5
echo "-----------------------------------"

echo # Start and Enable Services #
set -x
systemctl enable --now named
systemctl enable --now haproxy
systemctl enable --now httpd

