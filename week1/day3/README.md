# Week 1 / Day 3 — tcpdump BPF, flapping service, (optional) watchdog

## A. tcpdump BPF
### only_syn.pcap
```text
reading from file /home/ivanm/devops-labs/week1/day3/captures/only_syn.pcap, link-type EN10MB (Ethernet), snapshot length 262144
10:35:00.674226 IP 10.20.0.2.44144 > 10.20.0.1.8080: Flags [S], seq 1685592024, win 64240, options [mss 1460,sackOK,TS val 3778258270 ecr 0,nop,wscale 7], length 0
10:35:00.837185 IP 10.20.0.2.44154 > 10.20.0.1.8080: Flags [S], seq 1101304169, win 64240, options [mss 1460,sackOK,TS val 3778258434 ecr 0,nop,wscale 7], length 0
```

### http.pcap
```text
reading from file /home/ivanm/devops-labs/week1/day3/captures/http.pcap, link-type EN10MB (Ethernet), snapshot length 262144
10:35:18.725060 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [S], seq 2768211789, win 64240, options [mss 1460,sackOK,TS val 3778276322 ecr 0,nop,wscale 7], length 0
10:35:18.725295 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [S.], seq 3728928086, ack 2768211790, win 65160, options [mss 1460,sackOK,TS val 1219469426 ecr 3778276322,nop,wscale 7], length 0
10:35:18.725341 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [.], ack 1, win 502, options [nop,nop,TS val 3778276322 ecr 1219469426], length 0
10:35:18.725741 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [P.], seq 1:78, ack 1, win 502, options [nop,nop,TS val 3778276322 ecr 1219469426], length 77: HTTP: GET / HTTP/1.1
10:35:18.725772 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [.], ack 78, win 509, options [nop,nop,TS val 1219469426 ecr 3778276322], length 0
10:35:18.730683 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [P.], seq 1:156, ack 78, win 509, options [nop,nop,TS val 1219469431 ecr 3778276322], length 155: HTTP: HTTP/1.0 200 OK
10:35:18.730791 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [.], ack 156, win 501, options [nop,nop,TS val 3778276327 ecr 1219469431], length 0
10:35:18.730864 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [P.], seq 156:536, ack 78, win 509, options [nop,nop,TS val 1219469431 ecr 3778276327], length 380: HTTP
10:35:18.730887 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [.], ack 536, win 501, options [nop,nop,TS val 3778276327 ecr 1219469431], length 0
10:35:18.730982 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [F.], seq 536, ack 78, win 509, options [nop,nop,TS val 1219469431 ecr 3778276327], length 0
10:35:18.731618 IP 10.20.0.2.51458 > 10.20.0.1.8080: Flags [F.], seq 78, ack 537, win 501, options [nop,nop,TS val 3778276328 ecr 1219469431], length 0
10:35:18.731684 IP 10.20.0.1.8080 > 10.20.0.2.51458: Flags [.], ack 79, win 509, options [nop,nop,TS val 1219469432 ecr 3778276328], length 0
```

### icmp_drop.pcap
```text
tcpdump: truncated dump file; tried to read 4 file header bytes, only got 0
```

## B. systemd — echo-flap.service
### Status
```text
○ echo-flap.service - Flapping demo: fails 3 times, then runs on :18080
     Loaded: loaded (/home/ivanm/.config/systemd/user/echo-flap.service; enabled; preset: enabled)
     Active: inactive (dead) since Wed 2025-10-29 10:37:32 EET; 9min ago
   Duration: 25.188s
   Main PID: 11615 (code=killed, signal=TERM)
        CPU: 333ms

окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Scheduled restart job, restart counter is at 3.
окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:07 ivanm-VMware-Virtual-Platform ivanm[11616]: echo-flap started (post)
окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:37:07 ivanm-VMware-Virtual-Platform flap.sh[11615]: flap attempt 4 -> now running
окт 29 10:37:13 ivanm-VMware-Virtual-Platform flap.sh[11615]: 127.0.0.1 - - [29/Oct/2025 10:37:13] "GET / HTTP/1.1" 200 -
окт 29 10:37:32 ivanm-VMware-Virtual-Platform systemd[2938]: Stopping echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:32 ivanm-VMware-Virtual-Platform systemd[2938]: Stopped echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:38:04 ivanm-VMware-Virtual-Platform systemd[2938]: /home/ivanm/.config/systemd/user/echo-flap.service:13: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
окт 29 10:46:48 ivanm-VMware-Virtual-Platform systemd[2938]: /home/ivanm/.config/systemd/user/echo-flap.service:13: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
```

### Journal (tail)
```text
окт 29 10:37:00 ivanm-VMware-Virtual-Platform systemd[2938]: /home/ivanm/.config/systemd/user/echo-flap.service:13: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
окт 29 10:37:00 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:00 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:37:00 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Main process exited, code=exited, status=1/FAILURE
окт 29 10:37:00 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Failed with result 'exit-code'.
окт 29 10:37:03 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Scheduled restart job, restart counter is at 1.
окт 29 10:37:03 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:03 ivanm-VMware-Virtual-Platform ivanm[11599]: echo-flap started (post)
окт 29 10:37:03 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:37:03 ivanm-VMware-Virtual-Platform flap.sh[11598]: flap attempt 2 -> failing
окт 29 10:37:03 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Main process exited, code=exited, status=1/FAILURE
окт 29 10:37:03 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Failed with result 'exit-code'.
окт 29 10:37:05 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Scheduled restart job, restart counter is at 2.
окт 29 10:37:05 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:05 ivanm-VMware-Virtual-Platform flap.sh[11607]: flap attempt 3 -> failing
окт 29 10:37:05 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Main process exited, code=exited, status=1/FAILURE
окт 29 10:37:05 ivanm-VMware-Virtual-Platform ivanm[11608]: echo-flap started (post)
окт 29 10:37:05 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Failed with result 'exit-code'.
окт 29 10:37:05 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: echo-flap.service: Scheduled restart job, restart counter is at 3.
окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:07 ivanm-VMware-Virtual-Platform ivanm[11616]: echo-flap started (post)
окт 29 10:37:07 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:37:07 ivanm-VMware-Virtual-Platform flap.sh[11615]: flap attempt 4 -> now running
окт 29 10:37:13 ivanm-VMware-Virtual-Platform flap.sh[11615]: 127.0.0.1 - - [29/Oct/2025 10:37:13] "GET / HTTP/1.1" 200 -
окт 29 10:37:32 ivanm-VMware-Virtual-Platform systemd[2938]: Stopping echo-flap.service - Flapping demo: fails 3 times, then runs on :18080...
окт 29 10:37:32 ivanm-VMware-Virtual-Platform systemd[2938]: Stopped echo-flap.service - Flapping demo: fails 3 times, then runs on :18080.
окт 29 10:38:04 ivanm-VMware-Virtual-Platform systemd[2938]: /home/ivanm/.config/systemd/user/echo-flap.service:13: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
окт 29 10:46:48 ivanm-VMware-Virtual-Platform systemd[2938]: /home/ivanm/.config/systemd/user/echo-flap.service:13: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
```

## C. Watchdog (optional)
```text
● watchdog-demo.service - User-space watchdog demo
     Loaded: loaded (/home/ivanm/.config/systemd/user/watchdog-demo.service; disabled; preset: enabled)
     Active: active (running) since Wed 2025-10-29 10:46:51 EET; 29s ago
   Main PID: 12491 (bash)
      Tasks: 2 (limit: 2972)
     Memory: 568.0K (peak: 1.7M)
        CPU: 414ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/watchdog-demo.service
             ├─12491 bash /home/ivanm/devops-labs/week1/day3/watchdog.sh
             └─12543 sleep 2

окт 29 10:46:51 ivanm-VMware-Virtual-Platform systemd[2938]: watchdog-demo.service: Scheduled restart job, restart counter is at 6.
окт 29 10:46:51 ivanm-VMware-Virtual-Platform systemd[2938]: Starting watchdog-demo.service - User-space watchdog demo...
окт 29 10:46:51 ivanm-VMware-Virtual-Platform systemd[2938]: Started watchdog-demo.service - User-space watchdog demo.
```

## Краткие выводы дня
- BPF-фильтр SYN-only: `tcp[13] & 2 != 0 and tcp[13] & 16 = 0`.
- tcpdump `-w` сохраняет “сырые” пакеты для оффлайн-анализа (tcpdump -nr, Wireshark).
- Флапающему сервису задаём разумные `Restart` и `StartLimit*`.
- `ExecStartPost` — пост-действия сразу после старта процесса.
- Watchdog: `Type=notify`, `systemd-notify`, `WatchdogSec`.
