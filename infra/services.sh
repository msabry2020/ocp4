#!/bin/bash

# Set the variables
BASE_DOMAIN="nbe.com.eg"
PXE_DIR="/var/lib/tftpboot"
IP='192.168.50.111'
MAC='00:05:69:00:00'
DISK='sda'
DHCP_CONF="/etc/dhcp/dhcpd.conf"
DNS_CONF="/etc/named.conf"
ZONE_FILE="/var/named/${BASE_DOMAIN}.zone"
REVERSE_ZONE_FILE="/var/named/${BASE_DOMAIN}.reverse.zone"
HAPROXY_CONF="/etc/haproxy/haproxy.cfg"
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
HTTPD_ROOT_DIR="/var/www/html/openshift4"

# PXE # 
mkdir -p $PXE_DIR
sed -i "s/IP/${IP}/g" default
sed -i "s/disk/${DISK}/g" default
cp default ${PXE_DIR}/pxelinux.cfg
cp -r /usr/share/syslinux/* $PXE_DIR

# DHCP #
sed -i "s/MAC/${MAC}/g" dhcpd.conf
sed -i "s/IP/${IP}/g" dhcpd.conf
cp dhcpd.conf $DHCP_CONF

# DNS #
sed -i "s/IP/${IP}/g" ${BASE_DOMAIN}.zone
cp named.conf $DNS_CONF
cp ${BASE_DOMAIN}.zone $ZONE_FILE 
cp ${BASE_DOMAIN}.reverse.zone $REVERSE_ZONE_FILE 

# HAProxy #
cp haproxy.cfg $HAPROXY_CONF

# HTTPD # 
cp httpd.conf $HTTPD_CONF
mkdir -p ${HTTPD_ROOT_DIR}/images
mkdir -p ${HTTPD_ROOT_DIR}/ignitions
restorecon -Rv ${HTTPD_ROOT_DIR}

# Start and Enable Services #
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now tftp
systemctl enable --now haproxy
systemctl enable --now httpd

