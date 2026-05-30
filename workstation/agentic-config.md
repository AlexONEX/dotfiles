# Agentic Config — Reference

## Stack
```
OpenCode ──→ Meridian ──→ Claude Max (3 profiles)
```

## Dotfiles Structure
```tree
dotfiles/
├── opencode-config/
│   ├── opencode.json           # Theme: nord, provider: Meridian :3456
│   ├── agent/*.md              # 6 agents (architect, implement, test, etc.)
│   └── skills/*/SKILL.md      # 3 skills (secretary, assistant, executive)
├── meridian-config/
│   ├── profiles.json           # 3 Claude accounts
│   └── settings.json           # activeProfile: personal
├── claude-config/
│   └── settings.json           # dark-daltonized, vim, plugins
└── symlink-setup.sh            # Creates symlinks: dotfiles → system paths
```

**Setup on fresh machine:** `bash symlink-setup.sh`

## OpenCode (`~/.config/opencode/`)
- **Provider:** Meridian @ `http://127.0.0.1:3456` (apiKey=dummy)
- **Plugins:** `opencode-with-claude`, `meridian/plugin/meridian.ts`
- **6 agents:** architect-designer, big-picke-simple-tasks, implementation-specialist, requirements-clarifier, tech-lead, test-automation-engineer
- **3 skills:** secretary (capture), assistant (recall), executive (analyze)
- **Secretary DB:** `~/.config/opencode/secretary/secretary.db` (SQLite, 11 tables, FTS5)
- **Init:** `bash ~/.config/opencode/skills/init-secretary.sh`

## Meridian (`~/.config/meridian/`)
- **Install:** `npm install -g @rynfar/meridian`
- **Run:** `meridian` → binds `127.0.0.1:3456`
- **3 profiles:**
  | ID | Account | Config |
  |----|---------|--------|
  | `personal` | johndoelibertarian@gmail.com | `~/.claude/` (claude-max) |
  | `allaria` | alejandro.schwartzmann@allaria.com.ar | `~/.claude-allaria/` |
  | `alma` | alejandro.schwartzmann@almafintech.com.ar | `~/.claude-alma/` |
- **Switch:** `meridian profile switch <id>` or http://localhost:3456/profiles
- **SDK features:** http://localhost:3456/settings (enable Claude Prompt + Memory)

### Perfil `personal` — config
```json
{
  "id": "personal",
  "type": "claude-max",
  "claudeConfigDir": "/Users/alex/.claude",
  "description": "Personal — johndoelibertarian@gmail.com"
}
```
⚠️ **Siempre** incluir `claudeConfigDir` en perfiles `claude-max`. Sin él, Meridian usa el Claude bundled sin `CLAUDE_CONFIG_DIR`, y lee `~/.claude.json` (el archivo legacy), no el directorio `~/.claude/` con el profile correcto.

## Claude (`~/.claude/`)
- Theme: dark-daltonized | Editor: vim
- Plugins: everything-claude-code, pyright-lsp

## Restore Commands (fresh machine)
```bash
bash symlink-setup.sh                                 # symlink all configs
npm install -g @rynfar/meridian                       # install Meridian
meridian setup                                        # configure OpenCode plugin
bash ~/.config/opencode/skills/init-secretary.sh      # init secretary DB
meridian                                              # start proxy

# Each profile needs its own config dir and login:
mkdir -p ~/.claude ~/.claude-allaria ~/.claude-alma
CLAUDE_CONFIG_DIR=~/.claude        claude auth login     # personal (johndoelibertarian)
CLAUDE_CONFIG_DIR=~/.claude-allaria claude auth login    # allaria
CLAUDE_CONFIG_DIR=~/.claude-alma   claude auth login     # alma
```

## Key Commands
```bash
meridian                              # start proxy (runs in background)
meridian profile switch personal      # switch to personal account
meridian profile switch allaria       # switch to Allaria account
meridian profile switch alma          # switch to Alma account
meridian profile list                 # show all profiles with status
meridian setup                        # configure OpenCode plugin (one-time)
```

## Switching profiles in OpenCode

OpenCode envía el header `x-meridian-profile` automáticamente a través del plugin `meridian/plugin/meridian.ts`. Podés switchear con:

```bash
meridian profile switch personal   # todas las requests de OpenCode usan este profile
```

O por request individual desde OpenCode usando el agente `big-pickle-simple-tasks` con el perfil deseado.
