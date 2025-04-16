#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

#### Make changes to different directory #### 
cd ..
mkdir -p conf
cp config/* conf
cd conf

echo -e "# DNS Configuration #\n\n"
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
## named.conf ##
cp named.conf /etc/named.conf
cp forward.zone /var/named/${BASE_DOMAIN}.zone 
cp reverse.zone /var/named/${BASE_DOMAIN}.reverse.zone


echo -e "# HAProxy Configuration #\n"
sed -i "s/BOOTSTRAP_IP/${BOOTSTRAP_IP}/g" haproxy.cfg
sed -i "s/MASTER01_IP/${MASTER01_IP}/g" haproxy.cfg
sed -i "s/MASTER02_IP/${MASTER02_IP}/g" haproxy.cfg
sed -i "s/MASTER03_IP/${MASTER03_IP}/g" haproxy.cfg
sed -i "s/WORKER01_IP/${WORKER01_IP}/g" haproxy.cfg
sed -i "s/WORKER02_IP/${WORKER02_IP}/g" haproxy.cfg
cp haproxy.cfg /etc/haproxy/haproxy.cfg 
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1


echo -e "# HTTP Server Configuration #\n"
cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4


echo -e "# DHCP Server Configuration #\n"
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
sed -i "s/SUBNET/${SUBNET}/g" dhcpd.conf
sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" dhcpd.conf
cp dhcpd.conf /etc/dhcp/dhcpd.conf 

echo -e "# PXE Server Configuration #\n"
sed -i "s/HTTP_SERVER_IP/${UTIL_IP}/g" default
sed -i "s/DISK/${DISK}/g" default
mkdir /var/lib/tftpboot/pxelinux.cfg
cp default /var/lib/tftpboot/pxelinux.cfg
cp -r /usr/share/syslinux/* /var/lib/tftpboot

echo -e "# Start and Enable Services #"
set -x
systemctl enable --now dhcpd
systemctl enable --now named
systemctl enable --now haproxy
systemctl enable --now httpd
systemctl enable --now tftp

systemctl restart dhcpd
systemctl restart named
systemctl restart haproxy
systemctl restart httpd
systemctl restart tftp

systemctl status dhcpd named haproxy httpd tftp

