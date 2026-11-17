#!/bin/bash

OUTDIR="results/latency"
RAW="$OUTDIR/raw-results.csv"

mkdir -p "$OUTDIR"
echo "trial,start_timestamp,first_packet_timestamp,latency_ms" > "$RAW"

echo "========================================"
echo "Supplemental Detection Latency Experiment"
echo "Trials: 10"
echo "========================================"

for TRIAL in $(seq 1 10); do

    echo
    echo "Running latency trial $TRIAL..."

    CAPTURE="$OUTDIR/trial_${TRIAL}_capture.txt"
    rm -f "$CAPTURE"

    # Start a fresh packet capture for this trial
    docker exec security-gateway \
        sh -c "tcpdump -tt -l -n -i any 'src host 10.10.1.2 and dst host 10.10.2.3 and tcp dst port 80' -c 1 > /results/latency_capture.txt 2>/dev/null" &

    TCPDUMP_PID=$!

    sleep 1

    # Record initiation time immediately before the restricted request
    START=$(date +%s.%N)

    docker exec agent \
        curl --max-time 2 -s -o /dev/null http://10.10.2.3

    wait "$TCPDUMP_PID"

    docker cp security-gateway:/results/latency_capture.txt "$CAPTURE" >/dev/null

    FIRST_PACKET=$(awk 'NR==1 {print $1}' "$CAPTURE")

    LATENCY=$(awk -v start="$START" -v packet="$FIRST_PACKET" \
        'BEGIN {printf "%.3f", (packet-start)*1000}')

    echo "$TRIAL,$START,$FIRST_PACKET,$LATENCY" >> "$RAW"

    echo "Trial $TRIAL latency: $LATENCY ms"

    sleep 1
done

echo
echo "========================================"
echo "Latency experiment complete."
echo "Results saved to: $RAW"
echo "========================================"
