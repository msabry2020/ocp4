#!/bin/bash
set -x
echo '# Set the variables #'
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp412'
REVERSE_SUBNET='50.168.192'
INFRA_IP="192.168.50.254"
BOOTSTRAP_IP="192.168.50.9"
MASTER01_IP="192.168.50.10"
MASTER02_IP="192.168.50.11"
MASTER03_IP="192.168.50.12"
WORKER01_IP="192.168.50.13"
WORKER02_IP="192.168.50.14"
MAC='52:54:00:00:32'
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
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" forward.zone
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" forward.zone
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" forward.zone
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" forward.zone
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" forward.zone
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" forward.zone

## reverse.zone ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" reverse.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" reverse.zone
sed -i "s/INFRA/$(echo $INFRA_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BOOTSTRAP/$(echo $BOOTSTRAP_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER01/$(echo $MASTER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER02/$(echo $MASTER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER03/$(echo $MASTER03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER01/$(echo $WORKER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER02/$(echo $WORKER02_IP | awk -F. '{print $4}')/g" reverse.zone

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

echo '# PXE #'
set -x
sed -i "s/HTTP_SERVER_IP/${INFRA_IP}/g" default
sed -i "s/DISK/vda/g" default
mkdir /var/lib/tftpboot/pxelinux.cfg
cp default /var/lib/tftpboot/pxelinux.cfg
cp -r /usr/share/syslinux/* /var/lib/tftpboot
set +x
sleep 5
echo "-----------------------------------"

echo '# DHCP #'
set -x
cp dhcpd.conf /etc/dhcp/dhcpd.conf 
set +x
sleep 5
echo "-----------------------------------"

echo # Start and Enable Services #
set -x
systemctl enable --now dhcpd
systemctl enable --now tftp
systemctl enable --now named
systemctl enable --now haproxy
systemctl enable --now httpd
