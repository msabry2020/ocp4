#!/bin/bash

# Set the variables
BASE_DOMAIN='nbe.com.eg'
CLUSTER_NAME='cp4d'
INFRA_IP='192.168.50.111'
LB_OCT=$(echo $INFRA_IP | awk -F. '{print $4}')
MAC='00:05:69:00:00'
DISK='sda'

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
cp dhcpd.conf /etc/dhcp/dhcpd.conf 

# DNS #
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" named.conf 
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" forward.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" forward.zone
sed -i "s/INFRA_IP/${INFRA_IP}/g" forward.zone
sed -i "s/REGISTRY_IP/${REGISTRY_IP}/g" forward.zone
sed -i "s/LB_OCT/$LB_OCT/g" reverse.zone
sed -i "s/BASE_DOMAIN/${BASE_DOMAIN}/g" reverse.zone
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" reverse.zone
cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zon

# HAProxy #
cp haproxy.cfg /etc/haproxy/haproxy.cfg 

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

