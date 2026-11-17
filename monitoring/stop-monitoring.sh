#!/bin/sh

echo "Stopping network monitoring..."

pkill tcpdump 2>/dev/null || true

echo "Monitoring stopped."
