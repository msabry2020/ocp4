#!/bin/bash

source vars.sh
# Add the ports to the firewall
for port in "${PORTS[@]}"; do
  firewall-cmd --add-port=$port/tcp --zone $ZONE --permanent
done

# Add the services to the firewall
for service in "${SERVICES[@]}"; do
  firewall-cmd --add-service=$service --zone $ZONE --permanent
done

# Reload the firewall
firewall-cmd --reload
firewall-cmd --list-all
