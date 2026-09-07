---
name: manage-server
description: Manage the mars Debian 13 server (Tailscale, Pi-hole, nginx, media stack, Docker, systemd, LVM). Use for any service/config/deploy/infra change on mars. Enforces git discipline on /srv/repos/debian-server-management.
compatibility: Bash, git, systemctl, docker
---

# Mars Server Management

This machine IS mars. Source of truth: **`/srv/repos/debian-server-management`** — never rely on memory for what runs where; look it up.

## Golden Rules

1. Every change goes to the repo (configs, scripts, docs); commit before finishing (`feat:`/`fix:`/`chore:`/`docs:`).
2. **Never symlink systemd units from `/srv`** — it is a late-mounted LV; a unit unreadable at boot fails silently (this once took nginx down). Copy units as REAL files into `/etc/systemd/system/`. Units touching `/srv` need `After=srv.mount` + `Wants=srv.mount`.
3. Data in `/srv/data/<service>/` — never `/home/`, never the root LV (17G, nearly full). Check RAM/CPU/disk before adding anything.

## Where things are defined

| Need | Look in |
|---|---|
| Service catalog, ports, data dirs | `docs/SERVICES.md` + `.claude/server-context.md` |
| Per-service config + gotchas | `configs/<service>/README.md` |
| Docker services | `/opt/media-stack/docker-compose.yml` |
| Nginx vhosts (one HTTPS port per service, Tailscale cert) | `configs/nginx/sites-available/` → symlinked to `/etc/nginx/sites-enabled/` |
| Deploy / recovery / debug / templates | `scripts/deploy-*.sh` · `docs/QUICK_RECOVERY.md` · `docs/TROUBLESHOOTING.md` · `.claude/service-templates.md` |

Live state: `systemctl list-units --type=service --state=running`, `docker ps`, `systemctl --failed`, `df -h / /var /srv`. A service may be systemd OR Docker — check both.

## Criteria

- **New service**: Docker (dependency isolation); keep existing systemd services as-is.
- **New port**: not already listed in `docs/SERVICES.md`; expose via an nginx server block copied from an existing one. Tailscale-only — no public ports.
- **Checklist**: config in `configs/<service>/` or compose → data in `/srv/data/<service>/` → `scripts/deploy-<service>.sh` → document in `docs/SERVICES.md` → commit.
