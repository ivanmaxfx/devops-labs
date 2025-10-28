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
