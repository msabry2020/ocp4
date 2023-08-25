firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=22623/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-service=dns --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=tftp --permanent
firewall-cmd --reload
