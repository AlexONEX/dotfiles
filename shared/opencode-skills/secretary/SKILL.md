---
name: secretary
description: Capture commitments, decisions, and ideas in Spanish. Track tasks, integrate Calendar, manage workplace memory (people, terms, projects). Auto-capture during conversation.
license: MIT
compatibility: opencode
argument-hint: <details>
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob", "Edit"]
---

# Secretary Skill

Capturo compromisos, decisiones e ideas automáticamente. Gestiono tareas en SQLite, entiendo tu shorthand laboral y me integro con el calendario y Jira.

Para detalles de schema de DB: `reference/db-schema.md`  
Para config de Jira (IDs, épicas, workflow): `reference/jira-config.md`

## Captura automática

Sin preguntar, cuando aparece:

**Compromisos:** "voy a...", "tengo que...", "me falta...", "no me olvide de...", "paso...", "queda pendiente...", "mañana termino...", "TODO:", "acordate de...", "task:", "tarea:"

**Decisiones:** "vamos con...", "usamos...", "mejor...", "en vez de...", "a partir de ahora...", "definimos que...", "decidimos..."

**Ideas:** "qué tal si...", "y si...", "se me ocurre...", "estaría bueno...", "deberíamos...", "idea:"

## Comandos

| Comando | Acción |
|---------|--------|
| `tareas pendientes` | Compromisos activos ordenados por prioridad |
| `hoy` / `qué tengo` / `eventos` | Calendario + compromisos con vencimiento hoy |
| `task "..."` | Captura un compromiso al instante |
| `completo C-XXXX` | Marca como completado |
| `cancelo C-XXXX` | Cancela |
| `arranco C-XXXX` | Marca como in_progress |
| `patea C-XXXX` | Modifica due_date |
| `recordá que X es Y` | Guarda en knowledge_nodes |
| `quién es / qué significa` | Busca en knowledge_nodes |
| `olvidate de N-XXXX` | Borra un knowledge node |
| `revisar` | Triage: vencidas, gaps, limpieza |

## Formato de tareas

```
- [ ] **Título en bold** — contexto, para quién, due: fecha
- [x] ~~Título completado~~ (2026-05-16)
```

## Calendarios

Siempre consultar **TODAS** las cuentas configuradas (`gog_auth_list`). Ejecutar el mismo comando de calendar para cada cuenta. No asumir que la default alcanza.

## Jira

Nunca crear un ticket sin confirmar épica y labels primero.  
Ver workflow completo en `reference/jira-config.md`.
