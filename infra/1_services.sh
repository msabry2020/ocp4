#!/bin/bash

# Set the variables
BASE_DOMAIN='nbe.com.eg'
CLUSTER_NAME='cp4d'
SUBNET='192.168.50'
INFRA_IP="${SUBNET}.111"
REGISTRY_IP="${SUBNET}.222"
LB_OCT=$(echo $INFRA_IP | awk -F. '{print $4}')
MAC='00:05:69:00:00'
DISK='sda'

# Backup existing config files
cp /var/lib/tftpboot/pxelinux.cfg/default /var/lib/tftpboot/pxelinux.cfg/default.bkp
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
cp /etc/named.conf /etc/named.conf.bkp
cp /var/named/${BASE_DOMAIN}.zone /var/named/${BASE_DOMAIN}.zone.bkp
cp /var/named/${BASE_DOMAIN}.reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone.bkp

# PXE # 
sed -i "s/HTTP_SERVER_IP/${INFRA_IP}/g" default
sed -i "s/DISK/${DISK}/g" default
cp default /var/lib/tftpboot/pxelinux.cfg
cp -r /usr/share/syslinux/* /var/lib/tftpboot

# DHCP #
sed -i "s/MAC/${MAC}/g" dhcpd.conf
sed -i "s/GW/${INFRA_IP}/g" dhcpd.conf
sed -i "s/DNS/${INFRA_IP}/g" dhcpd.conf
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" dhcpd.conf
sed -i "s/SUBNET/${SUBNET}/g" dhcpd.conf
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" dhcpd.conf
cp dhcpd.conf /etc/dhcp/dhcpd.conf 

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
cp haproxy.cfg /etc/haproxy/haproxy.cfg 
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1

# HTTPD # 
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4/images
mkdir -p /var/www/html/openshift4/ignitions
restorecon -Rv /var/www/html/openshift4

# Start and Enable Services #
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now tftp
systemctl enable --now haproxy
systemctl enable --now httpd

