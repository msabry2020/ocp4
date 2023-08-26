#!/bin/bash

# Set the variables
BASE_DOMAIN="nbe.com.eg"
PXE_DIR="/var/lib/tftpboot/pxelinux.cfg/"
DHCP_CONF="/etc/dhcp/dhcpd.conf"
DNS_CONF="/etc/named.conf"
ZONE_FILE="/var/named/${BASE_DOMAIN}.zone"
REVERSE_ZONE_FILE="/var/named/${BASE_DOMAIN}.reverse.zone"
HAPROXY_CONF="/etc/haproxy/haproxy.cfg"
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
HTTPD_ROOT_DIR="/var/www/html/openshift4"

# PXE # 
mkdir -p $PXE_DIR
cp default $PXE_DIR
cp -r /usr/share/syslinux/* $PXE_DIR

# DHCP #
cp dhcpd.conf $DHCP_CONF

# DNS #
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
