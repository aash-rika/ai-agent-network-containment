#!/bin/sh

echo "========================================"
echo "Activating MONITORING configuration"
echo "========================================"

# Disable containment
iptables -F FORWARD
iptables -P FORWARD ACCEPT

# Stop an existing tcpdump process if one is running
pkill tcpdump 2>/dev/null || true

# Clear the previous monitoring log
: > /results/monitoring.log

# Start monitoring in the background
tcpdump -l -n -i any host 10.10.2.3 > /results/monitoring.log 2>&1 &

echo "Containment: OFF"
echo "Monitoring: ON"
echo "Monitoring restricted destination: 10.10.2.3"
echo "Log file: /results/monitoring.log"
