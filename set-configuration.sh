#!/bin/bash

CONFIGURATION="$1"

case "$CONFIGURATION" in

    baseline)
        echo "Setting configuration: BASELINE"
        docker exec security-gateway /stop-monitoring.sh
        docker exec security-gateway /baseline.sh
        ;;

    containment)
        echo "Setting configuration: CONTAINMENT"
        docker exec security-gateway /stop-monitoring.sh
        docker exec security-gateway /setup-firewall.sh
        ;;

    monitoring)
        echo "Setting configuration: MONITORING"
        docker exec security-gateway /stop-monitoring.sh
        docker exec security-gateway /baseline.sh
        docker exec -d security-gateway /start-monitoring.sh
        sleep 1
        ;;

    defense-in-depth)
        echo "Setting configuration: DEFENSE-IN-DEPTH"
        docker exec security-gateway /stop-monitoring.sh
        docker exec security-gateway /setup-firewall.sh
        docker exec -d security-gateway /start-monitoring.sh
        sleep 1
        ;;

    *)
        echo "Unknown configuration: $CONFIGURATION"
        echo "Valid configurations:"
        echo "  baseline"
        echo "  containment"
        echo "  monitoring"
        echo "  defense-in-depth"
        exit 1
        ;;
esac

echo "Configuration ready: $CONFIGURATION"
