#!/bin/bash

# Set the variables
PORTS=(6443 22623 443 80 8080)
SERVICES=(dns tftp)
ZONE="public"

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

