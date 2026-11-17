#!/bin/sh

echo "Configuring security gateway..."


# Remove existing FORWARD rules
iptables -F FORWARD

# Default forwarding policy
iptables -P FORWARD ACCEPT

# Block the agent from reaching the restricted server
iptables -A FORWARD \
  -s 10.10.1.2 \
  -d 10.10.2.3 \
  -j DROP

echo "Containment rule applied."

# Display current forwarding rules
iptables -L FORWARD -n -v
