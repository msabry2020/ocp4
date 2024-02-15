#!/bin/bash

echo "Load variables from vars file\n"
source vars.sh

echo "Add the ports to the firewall\n"
for port in "${PORTS[@]}"; do
  firewall-cmd --add-port=$port/tcp --zone $ZONE --permanent
done

echo "Add the services to the firewall\n"
for service in "${SERVICES[@]}"; do
  firewall-cmd --add-service=$service --zone $ZONE --permanent
done

echo "Reload the firewall\n"
firewall-cmd --reload
firewall-cmd --list-all
