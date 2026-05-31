---
name: manage-server
description: Manage the mars Debian 13 server. Covers infrastructure (Tailscale, Pi-hole, nginx), media stack (Sonarr/Radarr/Jellyfin/qBittorrent/Prowlarr), Docker, systemd, LVM, and service deployment. Enforces git discipline on /srv/repos/debian-server-management.
compatibility: Bash, git, systemctl, docker
---

# Mars Server Management

## Golden Rules

1. Every change goes to the repo — configs, scripts, docs
2. Configs in repo, symlink to system — never edit `/etc/systemd/system/` directly
3. Data in `/srv/` — never in `/home/` nor on root LV
4. Commit before finishing — conventional messages (`feat:`, `fix:`, `chore:`, `docs:`)
5. Before adding a service: check RAM/CPU/disk impact. Root LV is small (17G); VG is nearly full.

---

## Discovering the Current State

Run these at the start of any session to understand what's live:

```bash
# All running systemd services (non-trivial ones)
systemctl list-units --type=service --state=running | grep -v '\(getty\|dbus\|syslog\|systemd\|accounts\|polkit\|rsyslog\|cron\|ssh\|avahi\|nm-\|ModemManager\|packagekit\|udisks\|colord\|rtkit\|bluetooth\)'

# Docker containers (both systemd-managed and standalone)
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Active timers
systemctl list-timers --all | grep -v "n/a"

# Disk
df -h / /var /srv

# Failed anything
systemctl --failed

# Find a service (could be systemd or docker)
# Systemd: systemctl status <service>
# Docker: docker ps | grep <service> or docker logs <container>
```

Config for every service lives at:
- **Systemd** (bare metal): `/srv/repos/debian-server-management/configs/<service>/`
- **Docker** (containerized): `/opt/media-stack/docker-compose.yml`
- Nginx: `/etc/nginx/sites-enabled/media-apps-https.conf` (symlinked from repo)

**Note:** Media apps (Sonarr, Radarr, Prowlarr, Jellyfin, qBittorrent, etc.) can run either way—check both systemd services and docker containers.

---

## Directory Structure

```
/srv/
├── repos/          # All git repos (~/Github symlinks here)
│   └── debian-server-management/
├── media/          # Jellyfin library (movies/, tv/)
├── torrents/       # qBittorrent (incomplete/, movies/, tv/)
└── data/           # Persistent app data
    ├── pihole/     # Pi-hole volumes (etc-pihole/, etc-dnsmasq/)
    ├── calibre/
    ├── stacks/
    ├── lncrawl/
    ├── your-spotify/
    └── papers/

/opt/media-stack/   # Docker compose for media + Pi-hole
/etc/nginx/         # Nginx config (sites-enabled/ symlinked from repo)
/etc/ssl/tailscale/ # TLS cert for mars.tail56f9e.ts.net
```

LVM layout:
| LV | Mount | Size | Note |
|----|-------|------|------|
| mars-vg/root | `/` | 17G | System, /opt, /home |
| mars-vg/var | `/var` | 6.6G | Logs, Docker metadata |
| mars-vg/srv | `/srv` | 208G | All data |

> VG is nearly full. Growing an LV requires shrinking another from a live USB.

---

## Core Infrastructure

### Tailscale

- Tailnet: `tail56f9e.ts.net` | mars IP: `100.79.95.44`
- mars runs with `--accept-dns=false` — it manages DNS via systemd-resolved, not Tailscale MagicDNS
- mars advertises an exit node
- All services are accessible only via Tailscale (no public ports except SSH 22)
- Config: `configs/tailscaled/`

### Pi-hole

Runs as a **Docker container** in `/opt/media-stack/docker-compose.yml`.

DNS chain on mars:
```
app → systemd-resolved (127.0.0.53) → Pi-hole (127.0.0.1:53) → 1.1.1.1
```

DNS chain from any Tailscale device (Mac, Android):
```
device → MagicDNS (100.100.100.100) → Pi-hole (100.79.95.44:53) → 1.1.1.1
```

Critical constraints:
- Pi-hole binds to `127.0.0.1:53` (NOT `0.0.0.0:53`) — systemd-resolved owns `127.0.0.53:53` and the kernel rejects `0.0.0.0` as overlapping
- Pi-hole also binds to `100.79.95.44:53` so Tailscale peers can reach it
- Pi-hole web UI at `127.0.0.1:8088` (Docker bridge), proxied by nginx at port 8447
- Tailscale admin (login.tailscale.com/admin/dns): global nameserver = `100.79.95.44`, Override local DNS = on
- `/etc/systemd/resolved.conf`: `DNS=127.0.0.1` and `Domains=~.` (forwards everything to Pi-hole)
- No web password — server only reachable via Tailscale

Restart after Tailscale is up if port 53 binding fails:
```bash
cd /opt/media-stack && docker compose restart pihole
ss -tlunp | grep 53   # should show both 127.0.0.1:53 and 100.79.95.44:53
```

### Nginx

Not managed by a standard `nginx.service` unit — starts via init.d (`S01nginx`).

```bash
sudo nginx            # start
sudo nginx -s reload  # reload (graceful, use this after config changes)
sudo nginx -t         # validate config before reloading
```

All services are exposed via HTTPS on distinct ports (no subdomains). TLS cert is the Tailscale-issued cert at `/etc/ssl/tailscale/mars.tail56f9e.ts.net.{crt,key}`.

Config in repo: `configs/nginx/sites-available/media-apps-https.conf`
Symlinked to: `/etc/nginx/sites-enabled/media-apps-https.conf`

To add a new service, append a server block:
```nginx
server {
    listen <port> ssl http2;
    listen [::]:<port> ssl http2;
    server_name mars.tail56f9e.ts.net;
    ssl_certificate /etc/ssl/tailscale/mars.tail56f9e.ts.net.crt;
    ssl_certificate_key /etc/ssl/tailscale/mars.tail56f9e.ts.net.key;
    location / { proxy_pass http://127.0.0.1:<backend_port>; include proxy_params; }
}
```

---

## Procedures

### Add a systemd service (bare metal)

```bash
mkdir -p configs/<service>
# create <service>.service (use existing ones as template)
sudo ln -sf /srv/repos/debian-server-management/configs/<service>/<service>.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now <service>
```

### Add a Docker service (containerized)

Edit `/opt/media-stack/docker-compose.yml`. Data volumes go in `/srv/data/<service>/`. Then:
```bash
cd /opt/media-stack && docker compose up -d <service>
```

**Note:** Many services can run either way. Prefer systemd if already deployed; prefer Docker for new deployments to isolate dependencies.

### Renew Tailscale TLS cert

```bash
./backups/scripts/renew-tailscale-cert.sh
sudo nginx -s reload
```

### Commit changes

```bash
cd /srv/repos/debian-server-management
git add <files>
git commit -m "<type>: <description>"
```

---

## Troubleshooting

### Systemd service fails
```bash
systemctl status <service> --no-pager
journalctl -u <service> -n 50 --no-pager
```

### Docker container fails
```bash
docker logs <container> --tail 50
```

### Disk full (root LV)
```bash
du -sh /* 2>/dev/null | sort -rh | head -15
rm -rf ~/.cache/camoufox ~/.cache/ms-playwright ~/.cache/pip ~/.cache/node-gyp ~/.npm/_cacache
docker system prune -f
```

### Pi-hole port 53 conflict
Symptom: `CRIT: failed to create listening socket for port 53: Address in use`

systemd-resolved owns `127.0.0.53:53`. Pi-hole must bind to `127.0.0.1:53` (not `0.0.0.0:53`). Verify docker-compose ports and restart after Tailscale is up.

### Pi-hole not reachable from Tailscale peers
`docker compose restart pihole` — the `100.79.95.44:53` binding fails if Tailscale interface was down at container start.

### Pi-hole web 403
Access via hostname, not IP: `https://mars.tail56f9e.ts.net:8447/`

### qBittorrent high RAM (memory-mapped files)
```bash
# Disable mmap via API (login first, get SID cookie, then):
curl -s -b "SID=$SID" -X POST "http://localhost:8090/api/v2/app/setPreferences" \
    -d 'json={"memory_working_set_limit":512}'
```

### Media not appearing in Jellyfin
1. Verify path: `ls /srv/media/tv/<Series>/Season X/`
2. Trigger scan: Jellyfin → Dashboard → Libraries → Scan

### FlareSolverr ERR_NAME_NOT_RESOLVED
Add `dns: [1.1.1.1, 8.8.8.8]` to flaresolverr service in docker-compose and recreate.

---

## Recovery from Scratch

```bash
git clone <repo> /srv/repos/debian-server-management
cd /srv/repos/debian-server-management

./scripts/deploy-nginx.sh
./scripts/deploy-fail2ban.sh
./scripts/deploy-tailscaled.sh
./scripts/deploy-pihole.sh      # or: cd /opt/media-stack && docker compose up -d pihole

./scripts/deploy-sonarr.sh
./scripts/deploy-radarr.sh
./scripts/deploy-prowlarr.sh
./scripts/deploy-qbittorrent.sh
./scripts/deploy-jellyfin.sh

cd /opt/media-stack && docker compose up -d

./scripts/deploy-calibre.sh
./scripts/deploy-papers.sh
./scripts/deploy-samba.sh
```
