#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$HOME/devops-labs}"
mkdir -p "$ROOT/week1/day2" "$ROOT/week1/day2/captures"

safe_run() { bash -lc "$1" 2>&1 || true; }

# --- собрать артефакты Day1 ---
# журнал пингера
safe_run 'journalctl --user -u pinger --since today --no-pager' > "$ROOT/week1/pinger_journal.txt"

# --- собрать артефакты Day2 (мягко, если чего-то нет) ---
PING_OUT=$(safe_run 'sudo ip netns exec cli ping -c1 -W1 10.20.0.1')
CURL_OUT=$(safe_run 'sudo ip netns exec cli curl -sS http://10.20.0.1:8080 | head -n 1')
NFT_OUT=$(safe_run 'sudo ip netns exec srv nft list ruleset | sed -n "1,80p"')
PCAP="$ROOT/week1/day2/captures/srv_cli.pcap"
PCAP_HEAD="(pcap not found)"
if [[ -f "$PCAP" ]]; then
  PCAP_HEAD=$(safe_run "tcpdump -nr '$PCAP' | head -n 20")
fi
SVC_STATUS=$(safe_run 'systemctl --user status echo-http.service --no-pager | sed -n "1,25p"')
SVC_JOURNAL=$(safe_run 'journalctl --user -u echo-http -n 50 --no-pager')

# --- week1/README.md ---
cat > "$ROOT/week1/README.md" <<'MD'
# Week 1 — Linux, systemd, сеть, фильтры, диагностика

## Цели
- Разобраться с user-юнитами systemd и таймерами.
- Потренироваться с netns/veth для локальной сетевой отладки.
- Освоить базовый ruleset nftables и захват трафика tcpdump.
- Собрать сервис с ExecStartPre/Restart и проиграть инцидент «порт занят».

## Краткий конспект
- **systemd**: `ExecStart` (старт), `ExecStartPre` (предпроверки), `Restart=on-failure/always`, `OnCalendar`/`Persistent=true`.
- **Readiness/Liveness/Startup**: трафик vs рестарт vs долгий старт.
- **nftables**: policy drop + `ct state established,related accept` → не рвём established-потоки.
- **tcpdump**: `-w file.pcap` для оффлайн-анализа; `tcpdump -nr file` или Wireshark.

## Артефакты
- `week1/pinger_journal.txt` — лог таймера.
- `week1/day2/README.md` — подробные результаты по nftables/tcpdump/systemd.
MD

# --- week1/day2/README.md ---
cat > "$ROOT/week1/day2/README.md" <<MD
# Week 1 / Day 2 — nftables, tcpdump/pcap, systemd (инцидент)

## A. nftables в namespace
**Проверки:**
### ping (ожидаем FAIL)
\`\`\`text
$ sudo ip netns exec cli ping -c1 -W1 10.20.0.1
${PING_OUT}
\`\`\`

### curl к 8080 (ожидаем 200 и HTML)
\`\`\`html
${CURL_OUT}
\`\`\`

### Ruleset (фрагмент)
\`\`\`text
${NFT_OUT}
\`\`\`

## B. tcpdump / pcap
Файл: \`week1/day2/captures/srv_cli.pcap\`

**Первые строки:**
\`\`\`text
${PCAP_HEAD}
\`\`\`

## C. systemd: ExecStartPre и инцидент «порт занят»
### Статус сервиса
\`\`\`text
${SVC_STATUS}
\`\`\`

### Журнал (последние 50 строк)
\`\`\`text
${SVC_JOURNAL}
\`\`\`

## Ответы на вопросы дня (конспект)
1) **ExecStartPre** — предпроверки перед стартом (порт свободен, БД/секреты доступны, миграции готовы).  
2) **ct state established,related accept** — пропускаем ответы/установленные соединения; без этого разорвём обратный трафик (ACK/ESTABLISHED).  
3) **tcpdump -w file.pcap** — сырая запись для пост-анализа (tcpdump -nr, Wireshark), удобно делиться артефактом и разбирать оффлайн.
MD

# --- git-коммит ---
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$ROOT" add week1/README.md week1/pinger_journal.txt week1/day2/README.md
  git -C "$ROOT" commit -m "week1: regenerate READMEs from scripts" || true
fi

echo "Week1 docs updated -> $ROOT/week1"
