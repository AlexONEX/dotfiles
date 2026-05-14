# Secretary Skill - OpenCode Quick Start

3 skills installed:

| Skill | Directory | What it does |
|-------|-----------|-------------|
| `secretary` | `~/.config/opencode/skills/secretary/` | Capture commitments, decisions, ideas |
| `assistant` | `~/.config/opencode/skills/assistant/` | Briefings, memory recall, knowledge graph |
| `executive` | `~/.config/opencode/skills/executive/` | Prioritization, analytics, reviews |

## Setup (one time)
```bash
bash ~/.config/opencode/skills/init-secretary.sh
```

## Usage
Just ask naturally: "Capture this decision", "What's pending?", "Give me a briefing"

## No hooks = manual capture at session end
OpenCode lacks Claude Code's hook system. End sessions with:
> "Review this session and record any commitments, decisions, and ideas"

## Meridian settings (http://localhost:3456/settings)
- Claude Code Prompt: on  |  Client Prompt: on  |  Memory: on  |  Thinking: adaptive
