#!/bin/sh

echo "========================================"
echo "Activating BASELINE configuration"
echo "========================================"

# Remove existing forwarding rules
iptables -F FORWARD

# Allow forwarding by default
iptables -P FORWARD ACCEPT

echo "Containment disabled."
echo "All forwarded traffic is allowed."
echo

iptables -L FORWARD -n -v --line-numbers
