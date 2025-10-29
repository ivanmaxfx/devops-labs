#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$HOME/devops-labs}"
mkdir -p "$ROOT/week1/day3" "$ROOT/week1/day3/captures"

safe() { bash -lc "$1" 2>&1 || true; }

# Соберём снэпшоты
SYN_HEAD=$(safe "tcpdump -nr '$ROOT/week1/day3/captures/only_syn.pcap' | head -n 12")
HTTP_HEAD=$(safe "tcpdump -nr '$ROOT/week1/day3/captures/http.pcap' | head -n 12")
ICMP_HEAD=$(safe "tcpdump -nr '$ROOT/week1/day3/captures/icmp_drop.pcap' | head -n 10")

FLAP_STATUS=$(safe "systemctl --user status echo-flap.service --no-pager | sed -n '1,25p'")
FLAP_LOG=$(safe "journalctl --user -u echo-flap -n 60 --no-pager")

WD_STATUS=$(safe "systemctl --user status watchdog-demo.service --no-pager | sed -n '1,25p'")

# README
cat > "$ROOT/week1/day3/README.md" <<MD
# Week 1 / Day 3 — tcpdump BPF, flapping service, (optional) watchdog

## A. tcpdump BPF
### only_syn.pcap
\`\`\`text
${SYN_HEAD:-"(no pcap yet)"}
\`\`\`

### http.pcap
\`\`\`text
${HTTP_HEAD:-"(no pcap yet)"}
\`\`\`

### icmp_drop.pcap
\`\`\`text
${ICMP_HEAD:-"(no pcap yet)"}
\`\`\`

## B. systemd — echo-flap.service
### Status
\`\`\`text
${FLAP_STATUS}
\`\`\`

### Journal (tail)
\`\`\`text
${FLAP_LOG}
\`\`\`

## C. Watchdog (optional)
\`\`\`text
${WD_STATUS:-"(not started)"}
\`\`\`

## Краткие выводы дня
- BPF-фильтр SYN-only: \`tcp[13] & 2 != 0 and tcp[13] & 16 = 0\`.
- tcpdump \`-w\` сохраняет “сырые” пакеты для оффлайн-анализа (tcpdump -nr, Wireshark).
- Флапающему сервису задаём разумные \`Restart\` и \`StartLimit*\`.
- \`ExecStartPost\` — пост-действия сразу после старта процесса.
- Watchdog: \`Type=notify\`, \`systemd-notify\`, \`WatchdogSec\`.
MD

# Коммит
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$ROOT" add week1/day3/README.md
  git -C "$ROOT" commit -m "week1/day3: BPF + flapping service + (optional) watchdog docs" || true
fi
echo "Day3 docs updated -> $ROOT/week1/day3"
