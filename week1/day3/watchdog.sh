#!/usr/bin/env bash
set -euo pipefail
systemd-notify --ready
while true; do
  systemd-notify WATCHDOG=1
  sleep 2
done
