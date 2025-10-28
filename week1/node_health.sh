#!/usr/bin/env bash
set -euo pipefail
echo "TIME: $(date -Is)"
echo "UPTIME: $(uptime -p)"
echo "LOAD: $(cut -d' ' -f1-3 /proc/loadavg)"
MEM_LINE=$(LC_ALL=C free -m | awk 'NR==2 {printf "used=%sMB total=%sMB", $3, $2}')
echo "MEM: ${MEM_LINE}"
echo "DISK(/): $(df -h / | awk 'NR==2 {print $3"/"$2" used ("$5")"}')"
