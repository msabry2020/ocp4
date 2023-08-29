#!/bin/bash

# Set the variables
BASE_DOMAIN='nbe.ahly.bank'
CLUSTER_NAME='plz-vmware-sit-c01'
SUBNET='xxx.yyy.zzz'
REVERSE_SUBNET='xxx.yyy.zzz'
INFRA_IP="${SUBNET}.abc"
REGISTRY_IP="${SUBNET}.xyz"
LB_OCT=$(echo $INFRA_IP | awk -F. '{print $4}')

# Backup existing config files
cp /etc/named.conf /etc/named.conf.bkp
cp /var/named/${BASE_DOMAIN}.zone /var/named/${BASE_DOMAIN}.zone.bkp
cp /var/named/${BASE_DOMAIN}.reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone.bkp

# DNS #
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" named.conf 
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

# HAProxy #
sed -i "s/SUBNET/${SUBNET}/g" haproxy.cfg
cp haproxy.cfg /etc/haproxy/haproxy.cfg 
#semanage boolean -m --on haproxy_connect_any
#setsebool -P haproxy_connect_any=1

# HTTPD # 
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4/ignitions
restorecon -Rv /var/www/html/openshift4

# Start and Enable Services #
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now tftp
systemctl enable --now haproxy
systemctl enable --now httpd

