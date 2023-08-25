#PXE#
mkdir /var/lib/tftpboot/pxelinux.cfg/
/usr/bin/cp default /var/lib/tftpboot/pxelinux.cfg/
/usr/bin/cp -r /usr/share/syslinux/* /var/lib/tftpboot/

#DHCP#
/usr/bin/cp dhcpd.conf /etc/dhcp/dhcpd.conf

#DNS#
/usr/bin/cp named.conf /etc/named.conf
/usr/bin/cp nbe.com.eg.zone /var/named/
/usr/bin/cp nbe.com.eg.reverse.zone /var/named/

#LB#
/usr/bin/cp haproxy.cfg /etc/haproxy/haproxy.cfg
semanage boolean -m --on haproxy_connect_any
setsebool -P haproxy_connect_any=1


#HTTP#
/usr/bin/cp httpd.conf /etc/httpd/conf/httpd.conf
mkdir -p /var/www/html/openshift4/images
mkdir -p /var/www/html/openshift4/ignitions
restorecon -Rv /var/www/html/openshift4

systemctl enable --now dhcpd 
systemctl enable --now named
systemctl enable --now tftp
systemctl enable --now haproxy 
systemctl enable --now httpd
