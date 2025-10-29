import time, os
from systemd import daemon

# READY от основного процесса (этот же PID запущен systemd как main)
daemon.sd_notify('READY=1')

# период пингов: если systemd дал WATCHDOG_USEC — берём половину
wd_usec = int(os.environ.get('WATCHDOG_USEC', '0'))
interval = (wd_usec / 1_000_000.0) / 2 if wd_usec else 2.0

while True:
    daemon.sd_notify('WATCHDOG=1')
    time.sleep(interval)
