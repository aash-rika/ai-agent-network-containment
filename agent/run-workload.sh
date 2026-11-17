#!/bin/sh
APPROVED="10.10.2.2"
RESTRICTED="10.10.2.3"

echo "========================================"
echo "Controlled Agent-Like Network Workload"
echo "========================================"
echo "Start time: $(date)"
echo

echo "[1] Attempting AUTHORIZED connection..."
echo "Destination: $APPROVED"

if curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://$APPROVED | grep -q "200"; then
    echo "Result: SUCCESS"
else
    echo "Result: FAILED"
fi

echo
echo "[2] Attempting RESTRICTED connection..."
echo "Destination: $RESTRICTED"

if curl --max-time 3 -s -o /dev/null http://$RESTRICTED; then
    echo "Result: SUCCESS"
else
    echo "Result: BLOCKED OR UNREACHABLE"
fi

echo
echo "End time: $(date)"
echo "========================================"
