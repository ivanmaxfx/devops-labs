#!/usr/bin/env bash
set -euo pipefail
STATE="$HOME/.cache/flap.count"
mkdir -p "$(dirname "$STATE")"
cnt=0
[[ -f "$STATE" ]] && cnt=$(cat "$STATE" || echo 0)
cnt=$((cnt+1))
echo "$cnt" > "$STATE"

if (( cnt <= 3 )); then
  echo "flap attempt $cnt -> failing" >&2
  exit 1
else
  echo "flap attempt $cnt -> now running"
  exec python3 -m http.server 18080
fi
