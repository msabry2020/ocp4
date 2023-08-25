firewall-cmd --add-port=6443/tcp --zone trusted --permanent
firewall-cmd --add-port=22623/tcp --zone trusted --permanent
firewall-cmd --add-port=443/tcp --zone trusted --permanent
firewall-cmd --add-port=80/tcp --zone trusted --permanent
firewall-cmd --add-port=8080/tcp --zone trusted --permanent
firewall-cmd --add-service=dns --zone trusted --permanent
firewall-cmd --add-service=tftp --zone trusted --permanent
firewall-cmd --reload
