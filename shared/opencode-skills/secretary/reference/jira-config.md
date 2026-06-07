# Jira Config — Allaria Project

## Proyecto

| Campo | Valor |
|-------|-------|
| **Proyecto** | **DP** (Allaria Project) — NO AA (Allaria Agro) |
| **Cloud ID** | `91fb92aa-9455-4234-becd-7c1d232cdb46` |
| **Board** | 2 |
| **Account ID** | `712020:a803ac7d-3236-4e54-afb9-0e280a3e0a19` (Alejandro Schwartzmann) |
| **Equipo default** | `platform` (label, todo minúscula — case-sensitive) |
| **Assignee default** | Alejandro (él reasigna después) |

## Épicas frecuentes

| Key | Nombre |
|-----|--------|
| DP-11577 | Market Data |
| DP-16044 | Plataforma research / Market Data |
| DP-16496 | Sav3 |
| DP-1312 | Infrastructure improvements |
| DP-2922 | Deuda técnica BACK |

## Custom fields

| Campo | ID |
|-------|----|
| Story Points | `customfield_10016` |
| Sprint | `customfield_10020` |

Sprint activo: `sprint in openSprints() AND project = DP` → tomar `customfield_10020[0].id`

## Bug del MCP y workaround

`createJiraIssue`/`editJiraIssue` falla con custom fields numéricos (serializa mal el JSON).  
**Solución:** crear el ticket solo con summary/type/project, luego parchear con scripts:

```bash
# Setear campos (labels, SP, sprint, épica)
~/.config/opencode/skills/secretary/scripts/set-jira-fields.sh <KEY> '{"labels":["platform"],"customfield_10016":1,"customfield_10020":<sprintId>,"parent":{"key":"<EPIC>"}}'

# Mover a sprint
~/.config/opencode/skills/secretary/scripts/move-to-sprint.sh <sprintId> <KEY> [<KEY>...]
```

## Workflow crear ticket (orden exacto)

1. Preguntar épica (listar las frecuentes) y labels/equipo
2. `createJiraIssue` solo con `summary`, `issueTypeName`, `projectKey` — sin `additional_fields`
3. `set-jira-fields.sh` con: labels, SP, sprint, épica (`parent.key`)
4. `transitionJiraIssue` si va a Done/otro estado

## Decisiones registradas

- El proyecto es **DP**, no AA (AA es Allaria Agro)
- Labels son case-sensitive: `platform` ≠ `Platform`
- **Todo ticket nuevo va con sprint activo asignado** — sin sprint no aparece en el board (el board filtra por sprint activo)
- Siempre confirmar épica y equipo antes de crear
- **Naming convention market-data:** `[Nombre Épica] - descripción` (ej: `[Market Data] - escribir live prices dollar linked`)
- **Auto-sync Jira ↔ Secretary:** ticket Done → marcar commitment local como `completed`. Commitment local completado con `jira_key` → verificar si cerrar en Jira.

## Lecciones aprendidas

- **Sprint obligatorio** (2026-06-03): Creé DP-18327 sin sprint → no aparecía en el board a pesar de tener label `platform` y estar en To Do. Solución: asignar al Sprint activo (Sprint 77, id: 1349). El board de team-managed projects requiere que el issue esté en un sprint activo para visualizarse. Usar `editJiraIssue` con `{"customfield_10020": <sprintId>}`.
