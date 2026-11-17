#!/bin/sh

echo "Configuring agent route..."

# Route server-network traffic through the security gateway
ip route replace 10.10.2.0/24 via 10.10.1.3

echo "Agent route configured."

ip route
