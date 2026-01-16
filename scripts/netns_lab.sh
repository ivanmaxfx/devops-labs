#!/usr/bin/env bash
set -euo pipefail

# Всегда под sudo
if [[ $EUID -ne 0 ]]; then exec sudo -E bash "$0" "$@"; fi

NS_SRV=srv
NS_CLI=cli
VETH_SRV=veth-srv
VETH_CLI=veth-cli
IP_SRV=10.20.0.1/24
IP_CLI=10.20.0.2/24
PORT=8080

exists_ns(){ ip netns list 2>/dev/null | awk '{print $1}' | grep -qx "$1"; }

up() {
  exists_ns "$NS_SRV" || ip netns add "$NS_SRV"
  exists_ns "$NS_CLI" || ip netns add "$NS_CLI"

  # уберём возможные «хвосты» линков
  ip -n "$NS_SRV" link show "$VETH_SRV" &>/dev/null && ip -n "$NS_SRV" link del "$VETH_SRV" || true
  ip link show "$VETH_SRV" &>/dev/null && ip link del "$VETH_SRV" || true
  ip link show "$VETH_CLI" &>/dev/null && ip link del "$VETH_CLI" || true

  # создаём veth и разносим по ns
  ip link add "$VETH_SRV" type veth peer name "$VETH_CLI"
  ip link set "$VETH_SRV" netns "$NS_SRV"
  ip link set "$VETH_CLI" netns "$NS_CLI"

  # адреса + UP
  ip -n "$NS_SRV" addr add "$IP_SRV" dev "$VETH_SRV" 2>/dev/null || true
  ip -n "$NS_CLI" addr add "$IP_CLI" dev "$VETH_CLI" 2>/dev/null || true
  ip -n "$NS_SRV" link set lo up
  ip -n "$NS_CLI" link set lo up
  ip -n "$NS_SRV" link set "$VETH_SRV" up
  ip -n "$NS_CLI" link set "$VETH_CLI" up

  # nft rules в srv: drop по умолчанию, allow established, lo, и TCP 8080 с 10.20.0.2
  ip netns exec "$NS_SRV" bash -lc 'cat > /tmp/nft_srv.rules << "EOF"
flush ruleset
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iifname "lo" accept
    ip saddr 10.20.0.2 tcp dport 8080 accept
    counter log prefix "DROP " drop
  }
  chain forward { type filter hook forward priority 0; policy drop; }
  chain output  { type filter hook output  priority 0; policy accept; }
}
EOF
nft -f /tmp/nft_srv.rules
'

  # HTTP-сервер внутри srv
  ip netns exec "$NS_SRV" pkill -f "http.server $PORT" 2>/dev/null || true
  nohup ip netns exec "$NS_SRV" python3 -m http.server "$PORT" --bind 10.20.0.1 >/dev/null 2>&1 &
  sleep 0.5

  echo "[OK] lab up"
}

down() {
  ip netns exec "$NS_SRV" pkill -f "http.server $PORT" 2>/dev/null || true
  ip netns pids "$NS_SRV" 2>/dev/null | xargs -r kill -9 || true
  ip netns pids "$NS_CLI" 2>/dev/null | xargs -r kill -9 || true
  ip netns del "$NS_SRV" 2>/dev/null || true
  ip netns del "$NS_CLI" 2>/dev/null || true
  ip link del "$VETH_SRV" 2>/dev/null || true
  ip link del "$VETH_CLI" 2>/dev/null || true
  echo "[OK] lab down"
}

status() {
  ip netns list || true
  ip -n "$NS_SRV" addr show "$VETH_SRV" 2>/dev/null || true
  ip -n "$NS_CLI" addr show "$VETH_CLI" 2>/dev/null || true
  ip netns exec "$NS_SRV" ss -ltn "sport = :$PORT" 2>/dev/null || true
}

case "${1:-up}" in
  up)       up ;;
  down)     down ;;
  status)   status ;;
  *) echo "Usage: $0 {up|down|status}"; exit 1 ;;
esac
