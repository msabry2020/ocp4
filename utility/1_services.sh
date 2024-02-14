#!/bin/bash

echo '# Set the variables #'
BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
SUBNET="10.11.31"
REVERSE_SUBNET='31.11.10'
UTIL_IP="10.11.31.200"
BASTION_IP="10.11.31.199"
MASTER01_IP="10.11.31.201"
MASTER02_IP="10.11.31.202"
MASTER03_IP="10.11.31.203"
WORKER01_IP="10.11.31.204"
WORKER02_IP="10.11.31.205"
WORKER03_IP="10.11.31.206"
BOOTSTRAP_IP="10.11.31.210"
STORAGE_IP="10.11.31.211"
MAC="56:6f:c4:78:00"

echo "-----------------------------------"

echo '# DNS Configuration #'
## named.conf ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" named.conf 
sed -i "s/REVERSE_SUBNET/${REVERSE_SUBNET}/g" named.conf 

## forward.zone ##
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" forward.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" forward.zone
sed -i "s/UTIL_IP/${UTIL_IP}/g" forward.zone
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" forward.zone
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" forward.zone
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" forward.zone
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" forward.zone
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
sed -i "s/MASTER01/$(echo $MASTER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER02/$(echo $MASTER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/MASTER03/$(echo $MASTER03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER01/$(echo $WORKER01_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER02/$(echo $WORKER02_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/WORKER03/$(echo $WORKER03_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/BASTION/$(echo $BASTION_IP | awk -F. '{print $4}')/g" reverse.zone
sed -i "s/STORAGE/$(echo $STORAGE_IP | awk -F. '{print $4}')/g" reverse.zone

cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone
echo "-----------------------------------"


echo '# HAProxy Configuration #'
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
echo "-----------------------------------"

echo '# HTTP Server Configuration #'
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4
echo "-----------------------------------"

echo '# DHCP Server Configuration #'
sed -i "s/MAC/${MAC}/g" dhcpd.conf
sed -i "s/GW/${UTIL_IP}/g" dhcpd.conf
sed -i "s/DNS/${UTIL_IP}/g" dhcpd.conf
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" dhcpd.conf
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" dhcpd.conf
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" dhcpd.conf
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" dhcpd.conf
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" dhcpd.conf
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" dhcpd.conf
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" dhcpd.conf
sed -i "s/WORKER03_IP/${WORKER03_IP}/g" dhcpd.conf
sed -i "s/SUBNET/${SUBNET}/g" dhcpd.conf
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" dhcpd.conf
cp dhcpd.conf /etc/dhcp/dhcpd.conf 
echo "-----------------------------------"

echo # Start and Enable Services #
set -x
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now haproxy
systemctl enable --now httpd
