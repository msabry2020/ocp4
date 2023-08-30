#!/bin/bash

echo '# Set the variables #'
BASE_DOMAIN='nbe.ahly.bank'
CLUSTER_NAME='plz-vmware-sit-c01'
SUBNET='192.168.100'
REVERSE_SUBNET='100.168.192'
INFRA_IP="${SUBNET}.100"
REGISTRY_IP="${SUBNET}.105"
LB_OCT=$(echo $INFRA_IP | awk -F. '{print $4}')

echo '# Backup existing config files #'
set -x
cp /etc/named.conf /etc/named.conf.bkp
cp /var/named/${BASE_DOMAIN}.zone /var/named/${BASE_DOMAIN}.zone.bkp
cp /var/named/${BASE_DOMAIN}.reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone.bkp
set +x
sleep 5
echo "-----------------------------------"

echo '# DNS Configuration #'
set -x
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" named.conf 
sed -i "s/REVERSE_SUBNET/${REVERSE_SUBNET}/g" named.conf 
sed -i "s/SUBNET/${SUBNET}/g" forward.zone 
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" forward.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" forward.zone
sed -i "s/INFRA_IP/${INFRA_IP}/g" forward.zone
sed -i "s/REGISTRY_IP/${REGISTRY_IP}/g" forward.zone
sed -i "s/LB_OCT/$LB_OCT/g" reverse.zone
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" reverse.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" reverse.zone
cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone
set +x
sleep 5
echo "-----------------------------------"

echo '# HAProxy Configuration #'
set -x
sed -i "s/SUBNET/${SUBNET}/g" haproxy.cfg
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
