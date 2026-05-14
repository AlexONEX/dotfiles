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
│   └── settings.json           # activeProfile: gmail
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
  | `gmail` | johndoelibertarian@gmail.com | default (Claude Max) |
  | `work` | alejandro.schwartzmann@almafintech.com.ar | `~/.claude-work` |
  | `alt` | alejandro.schwartzmann@allaria.com.ar | `~/.claude-alt` |
- **Switch:** `meridian profile switch <id>` or http://localhost:3456/profiles
- **SDK features:** http://localhost:3456/settings (enable Claude Prompt + Memory)

## Claude (`~/.claude/`)
- Theme: dark-daltonized | Editor: vim
- Plugins: everything-claude-code, pyright-lsp

## Restore Commands
```bash
bash symlink-setup.sh                          # symlink all configs
npm install -g @rynfar/meridian                # install Meridian
meridian setup                                 # configure OpenCode plugin
claude login                                   # auth default profile
meridian profile add work                      # auth work profile
meridian profile add alt                       # auth alt profile
bash ~/.config/opencode/skills/init-secretary.sh  # init secretary DB
meridian                                       # start proxy
```

## Key Commands
```bash
meridian                              # start proxy
meridian profile switch work          # switch account
meridian setup                        # configure OpenCode plugin
```
