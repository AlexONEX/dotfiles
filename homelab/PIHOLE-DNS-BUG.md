# Pi-hole DNS Bug Diagnosis & Fix

## Symptoms
- `dig @127.0.0.1` / `dig @127.0.0.53` timeout (when FTL was running)
- `docker exec pihole dig @1.1.1.1` worked
- `ss` showed `0.0.0.0:53` with Recv-Q >200K, **no process attached** (ghost socket)
- FTL log: `CRIT: failed to create listening socket for port 53: Address in use`
- Mac lost internet when connected to Tailscale (exit node → server's broken DNS)

## Root Cause

### 1. systemd-resolved blocked 0.0.0.0:53
```
systemd-resolved owned:
  127.0.0.53:53  (stub, used by /etc/resolv.conf)
  127.0.0.54:53  (proxy)
```
Binding to `0.0.0.0:53` covers *all* interfaces including 127.0.0.x → `EADDRINUSE`.
Not visible in `ss` because systemd-resolved binds specific sub-IPs, but kernel rejects `0.0.0.0`.

### 2. FTL leaked sockets on each restart
Container `network_mode: host` → stale socket lingered on `0.0.0.0:53` after FTL crash/restart.
Accumulated DNS queries nobody consumed (Recv-Q). No port mapping to clean it up.

### 3. systemd-resolved had no upstream DNS
WiFi link DNS was empty. Only Tailscale DNS (`100.100.100.100`) existed.
Tailscale `--accept-dns` overrode everything with MagicDNS.

## Fix

### A. Docker compose: host → bridge networking
```yaml
# Before (broken)
network_mode: "host"
cap_add:
  - NET_ADMIN

# After (working)
ports:
  - "127.0.0.1:53:53/tcp"
  - "127.0.0.1:53:53/udp"
  - "80:80/tcp"
  - "443:443/tcp"
cap_add:
  - NET_ADMIN
  - NET_BIND_SERVICE
networks:
  - media-stack
```

### B. systemd-resolved → Pi-hole
```sh
resolvectl dns wlp0s20f3 127.0.0.1      # runtime
sudo tee /etc/systemd/resolved.conf <<< '[Resolve]\nDNS=127.0.0.1\nDomains=~.'
sudo systemctl restart systemd-resolved  # persist
```

### C. Tailscale: stop overriding DNS
```sh
sudo tailscale set --accept-dns=false
```

## Resulting DNS chain
```
host → systemd-resolved (127.0.0.53:53) → Pi-hole (127.0.0.1:53) → 1.1.1.1
```
