# Week 1 / Day 2 — nftables, tcpdump/pcap, systemd (инцидент)

## A. nftables в namespace
**Проверки:**
### ping (ожидаем FAIL)
```text
$ sudo ip netns exec cli ping -c1 -W1 10.20.0.1
PING 10.20.0.1 (10.20.0.1) 56(84) bytes of data.

--- 10.20.0.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
```

### curl к 8080 (ожидаем 200 и HTML)
```html
<!DOCTYPE HTML>
```

### Ruleset (фрагмент)
```text
table inet filter {
	chain input {
		type filter hook input priority filter; policy drop;
		ct state established,related accept
		iifname "lo" accept
		ip saddr 10.20.0.2 tcp dport 8080 accept
		counter packets 7 bytes 588 log prefix "DROP " drop
	}

	chain forward {
		type filter hook forward priority filter; policy drop;
	}

	chain output {
		type filter hook output priority filter; policy accept;
	}
}
```

## B. tcpdump / pcap
Файл: `week1/day2/captures/srv_cli.pcap`

**Первые строки:**
```text
reading from file /home/ivanm/devops-labs/week1/day2/captures/srv_cli.pcap, link-type EN10MB (Ethernet), snapshot length 262144
16:19:47.111145 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [S], seq 4103505998, win 64240, options [mss 1460,sackOK,TS val 3775099883 ecr 0,nop,wscale 7], length 0
16:19:47.111189 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [S.], seq 1544120476, ack 4103505999, win 65160, options [mss 1460,sackOK,TS val 1216292987 ecr 3775099883,nop,wscale 7], length 0
16:19:47.111202 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [.], ack 1, win 502, options [nop,nop,TS val 3775099883 ecr 1216292987], length 0
16:19:47.111277 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [P.], seq 1:78, ack 1, win 502, options [nop,nop,TS val 3775099883 ecr 1216292987], length 77: HTTP: GET / HTTP/1.1
16:19:47.111287 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [.], ack 78, win 509, options [nop,nop,TS val 1216292987 ecr 3775099883], length 0
16:19:47.112521 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [P.], seq 1:156, ack 78, win 509, options [nop,nop,TS val 1216292988 ecr 3775099883], length 155: HTTP: HTTP/1.0 200 OK
16:19:47.112572 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [.], ack 156, win 501, options [nop,nop,TS val 3775099884 ecr 1216292988], length 0
16:19:47.112720 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [P.], seq 156:495, ack 78, win 509, options [nop,nop,TS val 1216292989 ecr 3775099884], length 339: HTTP
16:19:47.112724 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [.], ack 495, win 501, options [nop,nop,TS val 3775099885 ecr 1216292989], length 0
16:19:47.112757 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [F.], seq 495, ack 78, win 509, options [nop,nop,TS val 1216292989 ecr 3775099885], length 0
16:19:47.112797 IP 10.20.0.2.35148 > 10.20.0.1.8080: Flags [F.], seq 78, ack 496, win 501, options [nop,nop,TS val 3775099885 ecr 1216292989], length 0
16:19:47.112868 IP 10.20.0.1.8080 > 10.20.0.2.35148: Flags [.], ack 79, win 509, options [nop,nop,TS val 1216292989 ecr 3775099885], length 0
16:19:47.140572 IP 10.20.0.2.35152 > 10.20.0.1.8080: Flags [S], seq 579959176, win 64240, options [mss 1460,sackOK,TS val 3775099912 ecr 0,nop,wscale 7], length 0
16:19:47.140621 IP 10.20.0.1.8080 > 10.20.0.2.35152: Flags [S.], seq 1176230515, ack 579959177, win 65160, options [mss 1460,sackOK,TS val 1216293017 ecr 3775099912,nop,wscale 7], length 0
16:19:47.140640 IP 10.20.0.2.35152 > 10.20.0.1.8080: Flags [.], ack 1, win 502, options [nop,nop,TS val 3775099913 ecr 1216293017], length 0
16:19:47.140926 IP 10.20.0.2.35152 > 10.20.0.1.8080: Flags [P.], seq 1:78, ack 1, win 502, options [nop,nop,TS val 3775099913 ecr 1216293017], length 77: HTTP: GET / HTTP/1.1
16:19:47.140948 IP 10.20.0.1.8080 > 10.20.0.2.35152: Flags [.], ack 78, win 509, options [nop,nop,TS val 1216293017 ecr 3775099913], length 0
16:19:47.141660 IP 10.20.0.1.8080 > 10.20.0.2.35152: Flags [P.], seq 1:156, ack 78, win 509, options [nop,nop,TS val 1216293018 ecr 3775099913], length 155: HTTP: HTTP/1.0 200 OK
16:19:47.141703 IP 10.20.0.2.35152 > 10.20.0.1.8080: Flags [.], ack 156, win 501, options [nop,nop,TS val 3775099914 ecr 1216293018], length 0
16:19:47.141731 IP 10.20.0.1.8080 > 10.20.0.2.35152: Flags [P.], seq 156:495, ack 78, win 509, options [nop,nop,TS val 1216293018 ecr 3775099914], length 339: HTTP
```

## C. systemd: ExecStartPre и инцидент «порт занят»
### Статус сервиса
```text
● echo-http.service - Simple echo HTTP on :8080 with preflight check
     Loaded: loaded (/home/ivanm/.config/systemd/user/echo-http.service; enabled; preset: enabled)
     Active: active (running) since Tue 2025-10-28 16:21:43 EET; 15min ago
   Main PID: 9124 (python3)
      Tasks: 1 (limit: 2972)
     Memory: 9.4M (peak: 9.9M)
        CPU: 385ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/echo-http.service
             └─9124 /usr/bin/python3 -m http.server 8080

окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:53 ivanm-VMware-Virtual-Platform python3[9124]: 127.0.0.1 - - [28/Oct/2025 16:21:53] "GET / HTTP/1.1" 200 -
окт 28 16:23:04 ivanm-VMware-Virtual-Platform python3[9124]: 127.0.0.1 - - [28/Oct/2025 16:23:04] "GET / HTTP/1.1" 200 -
```

### Журнал (последние 50 строк)
```text
окт 28 16:21:10 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:10 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:10 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:10 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:13 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 1.
окт 28 16:21:13 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:13 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:13 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:13 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:16 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 2.
окт 28 16:21:16 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:16 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:16 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:16 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:19 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 3.
окт 28 16:21:19 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:19 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:19 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:19 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:22 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 4.
окт 28 16:21:22 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:22 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:22 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:22 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:26 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 5.
окт 28 16:21:26 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:26 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:26 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:26 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:29 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 6.
окт 28 16:21:29 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:29 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:29 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:29 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:32 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 7.
окт 28 16:21:32 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:32 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Control process exited, code=exited, status=1/FAILURE
окт 28 16:21:32 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Failed with result 'exit-code'.
окт 28 16:21:32 ivanm-VMware-Virtual-Platform systemd[2938]: Failed to start echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:35 ivanm-VMware-Virtual-Platform systemd[2938]: echo-http.service: Scheduled restart job, restart counter is at 8.
окт 28 16:21:35 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:35 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Stopping echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Stopped echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Starting echo-http.service - Simple echo HTTP on :8080 with preflight check...
окт 28 16:21:43 ivanm-VMware-Virtual-Platform systemd[2938]: Started echo-http.service - Simple echo HTTP on :8080 with preflight check.
окт 28 16:21:53 ivanm-VMware-Virtual-Platform python3[9124]: 127.0.0.1 - - [28/Oct/2025 16:21:53] "GET / HTTP/1.1" 200 -
окт 28 16:23:04 ivanm-VMware-Virtual-Platform python3[9124]: 127.0.0.1 - - [28/Oct/2025 16:23:04] "GET / HTTP/1.1" 200 -
```

## Ответы на вопросы дня (конспект)
1) **ExecStartPre** — предпроверки перед стартом (порт свободен, БД/секреты доступны, миграции готовы).  
2) **ct state established,related accept** — пропускаем ответы/установленные соединения; без этого разорвём обратный трафик (ACK/ESTABLISHED).  
3) **tcpdump -w file.pcap** — сырая запись для пост-анализа (tcpdump -nr, Wireshark), удобно делиться артефактом и разбирать оффлайн.
