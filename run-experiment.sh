#!/bin/bash

RESULTS_FILE="results/experiments/results.csv"

CONFIGURATION="$1"
TRIAL="$2"

if [ -z "$CONFIGURATION" ] || [ -z "$TRIAL" ]; then
    echo "Usage: ./run-experiment.sh <configuration> <trial-number>"
    exit 1
fi

# Automatically set the requested experimental configuration
./set-configuration.sh "$CONFIGURATION" || exit 1

echo "========================================"
echo "Experimental Trial"
echo "Configuration: $CONFIGURATION"
echo "Trial: $TRIAL"
echo "========================================"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Test authorized destination
APPROVED_CODE=$(docker exec agent curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://10.10.2.2)

if [ "$APPROVED_CODE" = "200" ]; then
    APPROVED_RESULT="SUCCESS"
    LEGITIMATE_SUCCESS="YES"
else
    APPROVED_RESULT="FAILED"
    LEGITIMATE_SUCCESS="NO"
fi

# Test restricted destination
RESTRICTED_CODE=$(docker exec agent curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://10.10.2.3)

if [ "$RESTRICTED_CODE" = "200" ]; then
    RESTRICTED_RESULT="SUCCESS"
else
    RESTRICTED_RESULT="BLOCKED"
fi

# Determine whether the restricted attempt was detected
DETECTED="NA"
DETECTION_LATENCY="NA"

if [ "$CONFIGURATION" = "monitoring" ] || [ "$CONFIGURATION" = "defense-in-depth" ]; then
    # Give tcpdump a moment to flush captured packets to the log
    sleep 1

    if grep -q "10.10.1.2.*> 10.10.2.3.80" results/monitoring.log; then
        DETECTED="YES"
    else
        DETECTED="NO"
    fi
fi

echo "$TRIAL,$CONFIGURATION,$TIMESTAMP,10.10.2.2,AUTHORIZED,$APPROVED_RESULT,NA,NA,$LEGITIMATE_SUCCESS" >> "$RESULTS_FILE"
echo "$TRIAL,$CONFIGURATION,$TIMESTAMP,10.10.2.3,RESTRICTED,$RESTRICTED_RESULT,$DETECTED,$DETECTION_LATENCY,$LEGITIMATE_SUCCESS" >> "$RESULTS_FILE"

echo
echo "Authorized result: $APPROVED_RESULT"
echo "Restricted result: $RESTRICTED_RESULT"
echo "Results written to: $RESULTS_FILE"
