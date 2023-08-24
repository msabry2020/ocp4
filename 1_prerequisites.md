#PXE#
mkdir /var/lib/tftpboot/pxelinux.cfg/
/usr/bin/cp config/default /var/lib/tftpboot/pxelinux.cfg/
/usr/bin/cp -r /usr/share/syslinux/* /var/lib/tftpboot/

#DHCP#
/usr/bin/cp config/dhcpd.conf /etc/dhcp/dhcpd.conf

#DNS#
/usr/bin/cp config/named.conf /etc/named.conf
/usr/bin/cp config/ocp4demo.local.zone /var/named/
/usr/bin/cp config/ocp4demo.local.reverse.zone /var/named/

#LB#
/usr/bin/cp config/haproxy.cfg /etc/haproxy/haproxy.cfg
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1


#HTTP#
/usr/bin/cp config/httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4/images
mkdir -p /var/www/html/openshift4/ignitions
openshift-install coreos print-stream-json | grep -Eo '"https.*(kernel-|initramfs.|rootfs.)\w+(\.img)?"' | grep x86 | xargs wget -P /var/www/html/openshift4/images/
restorecon -Rv /var/www/html/openshift4
