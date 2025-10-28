#!/usr/bin/env bash
set -euo pipefail
echo "TIME: $(date -Is)"
echo "UPTIME: $(uptime -p)"
echo "LOAD: $(cut -d' ' -f1-3 /proc/loadavg)"
echo "MEM: $(free -m | awk '/Mem:/ {printf "used=%sMB total=%sMB\n", $3, $2}')"
echo "DISK(/): $(df -h / | awk 'NR==2 {print $3"/"$2" used ("$5")"}')"
