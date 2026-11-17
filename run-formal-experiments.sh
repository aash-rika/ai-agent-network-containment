#!/bin/bash

CONFIGURATIONS=("baseline" "containment" "monitoring" "defense-in-depth")
TRIALS=10

echo "========================================"
echo "Formal Experimental Run"
echo "Configurations: ${CONFIGURATIONS[*]}"
echo "Trials per configuration: $TRIALS"
echo "Total trials: 40"
echo "========================================"
echo

for CONFIG in "${CONFIGURATIONS[@]}"; do

    echo
    echo "########################################"
    echo "Configuration: $CONFIG"
    echo "########################################"

    for TRIAL in $(seq 1 "$TRIALS"); do

        echo
        echo "Running $CONFIG trial $TRIAL..."

        ./run-experiment.sh "$CONFIG" "$TRIAL"

        # Preserve monitoring evidence when monitoring is enabled
        if [ "$CONFIG" = "monitoring" ] || [ "$CONFIG" = "defense-in-depth" ]; then
            cp results/monitoring.log \
               "results/experiments/${CONFIG}_trial_${TRIAL}_monitoring.log"
        fi

        # Preserve firewall evidence when containment is enabled
        if [ "$CONFIG" = "containment" ] || [ "$CONFIG" = "defense-in-depth" ]; then
            docker exec security-gateway \
                iptables -L FORWARD -n -v --line-numbers \
                > "results/experiments/${CONFIG}_trial_${TRIAL}_firewall.txt"
        fi

    done
done

echo
echo "========================================"
echo "Formal experimental run completed."
echo "Results: results/experiments/results.csv"
echo "========================================"
