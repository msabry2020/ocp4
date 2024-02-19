packages='dhcp-server bind haproxy httpd'
PORTS=(6443 22623 443 80 8080)
SERVICES=(dns)
ZONE="public"
BASE_DOMAIN='adcb.com.eg'
CLUSTER_NAME='cp4d'
SUBNET="172.21.95"
REVERSE_SUBNET=$(echo "$SUBNET" | awk -F'.' '{print $3"."$2"."$1}')
BASTION_IP="172.21.95.130"
STORAGE_IP="172.21.95.132"
UTIL_IP="172.21.95.133"
MASTER01_IP="172.21.95.134"
MASTER02_IP="172.21.95.135"
MASTER03_IP="172.21.95.136"
WORKER01_IP="172.21.95.137"
WORKER02_IP="172.21.95.138"
WORKER03_IP="172.21.95.206"
BOOTSTRAP_IP="172.21.95.139"
MAC="00:50:56:b0"