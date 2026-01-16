# Week 1 / Day 4 — ss, nft counters, DNS/DoH, burst connections

## A. ss summary
```text
Total: 1
TCP:   188 (estab 0, closed 187, orphaned 0, timewait 10)

Transport Total     IP        IPv6
RAW	  0         0         0        
UDP	  0         0         0        
TCP	  1         1         0        
INET	  1         1         0        
FRAG	  0         0         0        
```

### :8080 snapshot
```text
State Recv-Q Send-Q Local Address:Port Peer Address:PortProcess
```

## B. nft INPUT counters (fragment)
```text
table inet filter {
	chain input { # handle 1
		type filter hook input priority filter; policy drop;
		ct state established,related accept # handle 4
		iifname "lo" accept # handle 5
		ip saddr 10.20.0.2 tcp dport 8080 counter packets 10 bytes 600 accept # handle 6
		counter packets 5 bytes 420 log prefix "DROP " drop # handle 7
	}
}
```

## C. DNS vs DoH
```text
dig A: 104.18.27.120,104.18.26.120
DoH A: 104.18.27.120,104.18.26.120
```

## D. nstat (TCP/IP metrics)
```text
IpInReceives                    17369              0.0
IpInHdrErrors                   0                  0.0
IpInAddrErrors                  1                  0.0
IpForwDatagrams                 63                 0.0
IpInUnknownProtos               0                  0.0
IpInDiscards                    0                  0.0
IpInDelivers                    17300              0.0
IpOutRequests                   6815               0.0
IpOutDiscards                   20                 0.0
IpOutNoRoutes                   0                  0.0
IpReasmTimeout                  0                  0.0
IpReasmReqds                    0                  0.0
IpReasmOKs                      0                  0.0
IpReasmFails                    0                  0.0
IpFragOKs                       0                  0.0
IpFragFails                     0                  0.0
IpFragCreates                   0                  0.0
IpOutTransmits                  6878               0.0
TcpActiveOpens                  24                 0.0
TcpPassiveOpens                 0                  0.0
```

## Notes
- accept/drop счётчики отражают HTTP/ICMP соответственно.
- ss -s: наблюдаем рост closed/timewait после бурста.
- DoH: шифрованный DNS поверх HTTPS.
