---
name: server-code
description: Navigate and modify all custom codebases on mars server. Use when the user wants to edit, debug, add features, or understand any of: Telegram bots, lncrawl, stacks, Calibre scripts, expenses bot, finance-tracking, life-tracker, personal-finance, arb-scanner, or any code under /srv/repos/ or /srv/data/. This is the go-to skill for "where is the code for X" or "let's modify Y feature".
compatibility: bash, python, typescript, rust
---

# Server Code Index

Central directory of all custom codebases on mars. Use this to locate code, understand project structure, and know where to make changes.

## Quick Reference

| Project | Location | Language | What it does |
|---------|----------|----------|--------------|
| **telegram-bot** | `/srv/repos/debian-server-management/scripts/telegram-bot.py` | Python | Mars master bot: services, books, Kindle |
| **expenses-bot** | `/srv/repos/expenses/` | TypeScript | Telegram expense tracking bot + dashboard |
| **lncrawl** | `/srv/data/lncrawl/` (data) + system install | Python | Light novel crawler |
| **stacks** | `/srv/data/stacks/` + `/srv/repos/debian-server-management/scripts/stacks-search.py` | Python | Comic/manga stack manager |
| **calibre-scripts** | `/srv/repos/debian-server-management/scripts/` | Bash/Python | calibre-import-lncrawl.sh, calibre-import-stacks.sh, download-book.sh, send-to-kindle.py, fix-epub-font-drm.py |
| **life-tracker** | `/srv/repos/life-tracker/` | TypeScript | Life logging bot (Telegram + PostgreSQL + web) |
| **finance-tracking** | `/srv/repos/finance-tracking/` | Python | Finance tracker with Google Sheets + Wealthfolio |
| **personal-finance** | `/srv/repos/personal-finance/` | Python | Portfolio analytics, salary projections |
| **personal-finance-html** | `/srv/repos/personal-finance-html/` | Python | Finance dashboard (HTML frontend) |
| **arb-scanner** | `/srv/repos/arb-scanner/` | Rust | Arbitrage scanner (IEL/Cedear markets) |
| **debian-server-management** | `/srv/repos/debian-server-management/` | Bash/Python | Server infra: deploy scripts, backups, configs |
| **dotfiles** | `/srv/repos/dotfiles/` | Bash | System dotfiles and setup scripts |
| **gitstatus** | `/srv/repos/gitstatus/` | Bash | Git prompt for bash |

---

## Detailed Project Maps

### 1. Telegram Bot (Master)
**File:** `/srv/repos/debian-server-management/scripts/telegram-bot.py`

Single-file bot that controls mars server via Telegram.

**Features:**
- Service management (start/stop/restart systemd + docker)
- Book management (Calibre library queries, send to Kindle)
- Novel management (lncrawl integration)
- Stack searches
- Server status

**Key dependencies:** `python-telegram-bot`, `sqlite3`, `subprocess`
**Config:** `/etc/telegram-bot/env` (BOT_TOKEN)
**Service:** `bot-master.service` (systemd)
**DB:** Reads Calibre's `/srv/data/calibre/metadata.db` directly

**To add a feature:** Edit the file directly. All handlers are defined as async functions. Use `calibredb` CLI or read `metadata.db` for book queries.

---

### 2. Expenses Bot
**Dir:** `/srv/repos/expenses/`

TypeScript Telegram bot for expense tracking with hledger.

**Structure:**
```
expenses/
├── src/                    # Bot source
│   ├── index.ts           # Entry point
│   ├── config/            # Configuration
│   ├── controllers/       # Command handlers
│   ├── models/            # Data models
│   ├── routes/            # HTTP routes (dashboard)
│   ├── services/          # Business logic
│   ├── scripts/           # Maintenance scripts
│   ├── types/             # TypeScript types
│   └── utils/             # Helpers
├── dashboard/             # Web dashboard (Vite + Tailwind)
│   ├── server/            # Dashboard backend
│   └── src/               # Dashboard frontend
├── scripts/               # Build/utility scripts
├── docker-compose.yml     # Deployment
└── package.json           # Dependencies
```

**Key commands:**
- `npm run dev` — watch mode
- `npm run build` — build bot + dashboard
- `npm run start` — start everything
- `npm run start:bot` — bot only

**Service:** Runs via Docker (see `docker-compose.yml`)
**Data:** `/srv/data/expenses-bot/`

---

### 3. Life Tracker
**Dir:** `/srv/repos/life-tracker/`

Life logging system: Telegram bot → PostgreSQL → Web UI.

**Structure:**
```
life-tracker/
├── classes/
│   ├── config.ts         # Configuration
│   ├── postgres.ts       # Database layer
│   └── telegram.ts       # Telegram integration
├── worker.ts             # Background job processor
├── scheduler.js          # Cron scheduling
├── web.ts                # Web server (dashboard)
├── init-db.js            # DB initialization
└── package.json
```

**Key:** TypeScript files have `.js` compiled counterparts. Edit `.ts` files.
**Database:** PostgreSQL (deployed via `deploy-life-tracker.sh`)
**Service:** `life-tracker.service` (systemd)

---

### 4. LNCrawl (Light Novel Crawler)
**Data:** `/srv/data/lncrawl/`

**Structure:**
```
lncrawl/
├── config.json           # App config (DB, crawler, calibre integration)
├── sqlite.db             # Novel database
├── novels/               # Downloaded novels (13 subdirs)
├── sources/              # Source definitions
├── images/               # Cover images
├── tmp/                  # Working directory
└── webdriver/            # Browser automation
```

**Config highlights:**
- Calibre API at `http://localhost:8182` (disabled, falls back to local)
- Proxy enabled, headless mode off
- Selenium grid configured

**Integration scripts (in debian-server-management):**
- `calibre-import-lncrawl.sh` — import novels to Calibre
- `lncrawl-auto-update.py` — auto-update crawler

---

### 5. Stacks (Comic/Manga Manager)
**Data:** `/srv/data/stacks/`

**Structure:**
```
stacks/
├── config.yaml           # Server config (port 7788, auth, FlareSolverr)
├── stacks.db             # SQLite database
├── download/             # Downloaded files
└── incoming/             # Incoming queue
```

**Config highlights:**
- Server on port 7788, auth enabled
- FlareSolverr integration for anti-bot bypass
- Download delay: 2s, retry: 3

**Search script:** `/srv/repos/debian-server-management/scripts/stacks-search.py`
**Integration:** `calibre-import-stacks.sh` imports to Calibre

---

### 6. Calibre Library & Scripts
**Library:** `/srv/data/calibre/myLibrary/`
**DB:** `/srv/data/calibre/metadata.db` (SQLite, Calibre v27)

**Scripts (all in `/srv/repos/debian-server-management/scripts/`):**

| Script | What it does |
|--------|-------------|
| `calibre-import-lncrawl.sh` | Import lncrawl novels to Calibre |
| `calibre-import-stacks.sh` | Import stacks comics to Calibre |
| `download-book.sh` | Download a book from URL |
| `send-to-kindle.py` | Send book to Kindle device |
| `fix-epub-font-drm.py` | Fix EPUB font DRM issues |
| `sync-to-kindle.sh` | Sync library to Kindle |

**Deploy:** `deploy-calibre.sh`
**Service:** `calibre-server` (systemd, port 8082)
**Content server:** Exposed via nginx at port 8443

---

### 7. Finance Tracking
**Dir:** `/srv/repos/finance-tracking/`

**Structure:**
```
finance-tracking/
├── main.py               # Entry point
├── api/                  # FastAPI backend
│   ├── main.py
│   └── database.py
├── src/config.py         # Configuration
├── scripts/              # Data import/processing
│   ├── export_to_wealthfolio.py
│   ├── import_to_wealthfolio.py
│   ├── update_market_data.py
│   ├── setup_historic_data.py
│   ├── create_dashboard.py
│   └── fix_sheet_formulas.py
├── frontend/             # Simple web frontend
├── data/                 # Raw + formatted data
├── docs/                 # Documentation
├── CLAUDE.md             # AI assistant context
├── CONTEXT.md            # Project context
└── STRUCTURE.md          # Architecture docs
```

**Deploy:** `finance-tracking.service` (systemd)
**Database:** Google Sheets + local SQLite

---

### 8. Personal Finance (HTML Dashboard)
**Dir:** `/srv/repos/personal-finance-html/`

**Structure:**
```
personal-finance-html/
├── main.py               # Entry point
├── src/                  # Core library
│   ├── config.py
│   └── __init__.py
├── scripts/              # Data processing
│   └── import_historical.py
├── backend/              # Python backend
├── frontend/             # HTML/JS frontend
├── systemd/              # Service files
├── bootstrap.py          # Initial setup
├── fetch_data.py         # Data fetching
├── fetch_portfolio_evolution.py
├── plot_rem_curves.py    # Salary projection charts
├── mark_ascensos.py      # Salary raise tracker
├── setup_sheet.py        # Google Sheets setup
├── setup_analisis.py     # Analysis setup
├── generate_columnas_doc.py
├── upload_to_inversiones.py
├── update_daily.sh       # Daily update script
├── pyproject.toml        # Python project config
└── docs/                 # Documentation
```

**Service:** Systemd (via `systemd/` directory)

---

### 9. ARB Scanner
**Dir:** `/srv/repos/arb-scanner/`

Rust-based arbitrage scanner for Cedear/IOL markets.

**Structure:**
```
arb-scanner/
├── src/                  # Rust source
├── frontend/             # Web dashboard
├── docs/                 # API docs (IOL Swagger)
├── Cargo.toml            # Rust project config
├── watchlist.json        # Tracked assets
├── update_watchlist.py   # Watchlist updater
└── test_c_sell.sh        # Test script
```

**Services:**
- `arb-scanner.service` — main scanner
- `arb-scanner.timer` — scheduled runs
- `arb-watchlist-update.service` — watchlist refresh
- `arb-watchlist-update.timer` — watchlist schedule

---

### 10. Debian Server Management
**Dir:** `/srv/repos/debian-server-management/`

The meta-repo: infrastructure as code for mars.

**Key scripts (in `scripts/`):**
- `deploy-*.sh` — Deploy each service
- `check-services.sh` — Health check all services
- `update-all-services.sh` — Update everything
- `weekly-maintenance.sh` — Weekly tasks
- `optimize-services.sh` — Resource optimization
- `backup-life-tracker.sh` — Backup LT data
- `restore-configs.sh` — Restore configs from backup
- `deduplicate-hardlinks.sh` — Storage optimization

**Configs:** `configs/` directory (symlinked to `/etc/`)
**Backups:** `backups/` directory

---

## How to Navigate

### Find code by feature
```
"busco el bot de telegram" → telegram-bot.py
"agregar gasto al bot de expenses" → expenses/src/controllers/
"modificar el crawler" → lncrawl config.json + calibre-import scripts
"agregar feature al life-tracker" → life-tracker/classes/
"editar el scanner de arbitraje" → arb-scanner/src/
```

### Find code by file type
```bash
# All Python files
find /srv/repos -name "*.py" | grep -v __pycache__ | grep -v .git

# All TypeScript files
find /srv/repos -name "*.ts" | grep -v node_modules | grep -v .git

# All Bash scripts
find /srv/repos -name "*.sh" | grep -v .git

# All Rust source
find /srv/repos -name "*.rs" | grep -v target | grep -v .git
```

### Find where a feature lives
```bash
# Search for a function/variable across all repos
rg "function_name" /srv/repos/ --type py --type ts --type rust

# Search for a string/config
rg "some_config" /srv/repos/ /srv/data/
```

---

## Common Operations

### Add a new Telegram bot command
1. Edit `/srv/repos/debian-server-management/scripts/telegram-bot.py`
2. Add handler function (async)
3. Register in `main()` with `app.add_handler()`
4. Restart: `sudo systemctl restart bot-master`

### Modify expenses bot
1. Edit files in `/srv/repos/expenses/src/`
2. `cd /srv/repos/expenses && npm run build`
3. Restart: `cd /srv/repos/expenses && docker compose restart`

### Change Calibre integration
1. Scripts: `/srv/repos/debian-server-management/scripts/calibre-import-*.sh`
2. DB queries: Read `/srv/data/calibre/metadata.db` (SQLite)
3. Config: `/srv/data/lncrawl/config.json` (calibre section)

### Add a deploy script
1. Create in `/srv/repos/debian-server-management/scripts/deploy-<service>.sh`
2. Use existing deploy scripts as template
3. Commit with `feat:` prefix

---

## Secrets & Config

| What | Where |
|------|-------|
| Telegram bot token | `/etc/telegram-bot/env` (BOT_TOKEN) |
| Expenses bot data | `/srv/data/expenses-bot/` |
| LNCrawl config | `/srv/data/lncrawl/config.json` |
| Stacks config | `/srv/data/stacks/config.yaml` |
| Calibre API | `http://localhost:8182` (disabled, local fallback) |
| Google credentials | `/srv/repos/*/credentials.json`, `/srv/repos/*/token.json` |
| Service accounts | `/srv/repos/finance-tracking/service_account.json` |
| Tailscale | Already configured, exit node active |

**Never commit:** credentials.json, token.json, .env files, service_account.json.
