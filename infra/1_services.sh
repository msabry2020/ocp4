#!/bin/bash
set -x
echo '# Set the variables #'
echo '# Set the variables #'
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
SUBNET="10.11.31"
REVERSE_SUBNET='31.11.10'
UTIL_IP="10.11.31.200"
CONTROL01_IP="10.11.31.201"
CONTROL02_IP="10.11.31.202"
CONTROL03_IP="10.11.31.203"
INFRA01_IP="10.11.31.204"
INFRA02_IP="10.11.31.205"
INFRA03_IP="10.11.31.206"
WORKER01_IP="10.11.31.207"
WORKER02_IP="10.11.31.208"
WORKER03_IP="10.11.31.209"
BOOTSTRAP_IP="10.11.31.210"
MAC="56:6f:c4:78:00:0"
BASTION_IP="10.11.31.200"
DISK='vda'
STORAGE_IP="10.11.31.211"

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
sed -i "s/UTIL_IP/${UTIL_IP}/g" forward.zone
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" forward.zone
sed -i "s/CONTROL01_IP/${CONTROL01_IP}/g" forward.zone
sed -i "s/CONTROL02_IP/${CONTROL02_IP}/g" forward.zone
sed -i "s/CONTROL03_IP/${CONTROL03_IP}/g" forward.zone
sed -i "s/INFRA01_IP/${INFRA01_IP}/g" forward.zone
sed -i "s/INFRA02_IP/${INFRA02_IP}/g" forward.zone
sed -i "s/INFRA03_IP/${INFRA03_IP}/g" forward.zone
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" forward.zone
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" forward.zone
sed -i "s/WORKER03_IP/${WORKER03_IP}/g" forward.zone
sed -i "s/BASTION_IP/${BASTION_IP}/g" forward.zone
sed -i "s/STORAGE_IP/${STORAGE_IP}/g" forward.zone

## reverse.zone ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" reverse.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" reverse.zone
sed -i "s/UTIL/$(echo $UTIL_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BOOTSTRAP/$(echo $BOOTSTRAP_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/CONTROL01/$(echo $CONTROL01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/CONTROL02/$(echo $CONTROL02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/CONTROL03/$(echo $CONTROL03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/INFRA01/$(echo $INFRA01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/INFRA02/$(echo $INFRA02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/INFRA03/$(echo $INFRA03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER01/$(echo $WORKER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER02/$(echo $WORKER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER03/$(echo $WORKER03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BASTION/$(echo $BASTION_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/STORAGE/$(echo $STORAGE_IP | awk -F. '{print $4}')/g" reverse.zone

cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone
set +x
sleep 5
echo "-----------------------------------"


echo '# HAProxy Configuration #'
set -x
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" haproxy.cfg
sed -i "s/CONTROL01_IP/${CONTROL01_IP}/g" haproxy.cfg
sed -i "s/CONTROL02_IP/${CONTROL02_IP}/g" haproxy.cfg
sed -i "s/CONTROL03_IP/${CONTROL03_IP}/g" haproxy.cfg
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" haproxy.cfg
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" haproxy.cfg
sed -i "s/WORKER03_IP/${WORKER03_IP}/g" haproxy.cfg
sed -i "s/INFRA01_IP/${INFRA01_IP}/g" haproxy.cfg
sed -i "s/INFRA02_IP/${INFRA02_IP}/g" haproxy.cfg
sed -i "s/INFRA03_IP/${INFRA03_IP}/g" haproxy.cfg

cp haproxy.cfg /etc/haproxy/haproxy.cfg 
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1
set +x
sleep 5
echo "-----------------------------------"

echo '# HTTP Server Configuration #'
set -x
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4
#restorecon -Rv /var/www/html/openshift4
set +x
sleep 5
echo "-----------------------------------"

echo '# PXE Server Configuration #'
sed -i "s/HTTP_SERVER_IP/${UTIL_IP}/g" default
sed -i "s/DISK/${DISK}/g" default
mkdir /var/lib/tftpboot/pxelinux.cfg
cp default /var/lib/tftpboot/pxelinux.cfg
cp -r /usr/share/syslinux/* /var/lib/tftpboot
set +x
sleep 5
echo "-----------------------------------"

echo '# DHCP Server Configuration #'
sed -i "s/MAC/${MAC}/g" dhcpd.conf
sed -i "s/GW/${UTIL_IP}/g" dhcpd.conf
sed -i "s/DNS/${UTIL_IP}/g" dhcpd.conf
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" dhcpd.conf
sed -i "s/SUBNET/${SUBNET}/g" dhcpd.conf
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" dhcpd.conf
cp dhcpd.conf /etc/dhcp/dhcpd.conf 
set +x
sleep 5
echo "-----------------------------------"

echo # Start and Enable Services #
set -x
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now tftp
systemctl enable --now haproxy
systemctl enable --now httpd
