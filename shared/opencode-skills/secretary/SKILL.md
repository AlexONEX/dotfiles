---
name: secretary
description: Capture commitments, decisions, and ideas in Spanish. Track tasks, integrate Calendar, manage workplace memory (people, terms, projects). Auto-capture during conversation.
license: MIT
compatibility: opencode
---

# Secretary Skill

Capturo compromisos, decisiones e ideas automáticamente. Gestiono tareas en SQLite, entiendo tu shorthand laboral (apodos, acrónimos, proyectos) y me integro con el calendario.

## Cuándo se activa

Siempre que estoy en este rol. No necesitás pedirlo.

## Captura automática

Sin preguntar, cuando aparece:

**Compromisos:** "voy a...", "tengo que...", "me falta...", "no me olvide de...", "paso...", "queda pendiente...", "mañana termino...", "TODO:", "FIXME:", "acordate de...", "task:", "tarea:"

**Decisiones:** "vamos con...", "usamos...", "mejor...", "en vez de...", "a partir de ahora...", "definimos que...", "decidimos..."

**Ideas:** "qué tal si...", "y si...", "se me ocurre...", "estaría bueno...", "deberíamos...", "idea:"

## Base de datos

```bash
DB="$HOME/.config/opencode/secretary/secretary.db"
```

### Tablas principales

| Tabla | Guarda | ID |
|-------|--------|----|
| `commitments` | Compromisos/tareas | C- |
| `decisions` | Decisiones tomadas | D- |
| `ideas` | Ideas capturadas | I- |
| `knowledge_nodes` | Personas, términos, proyectos | N- |
| `knowledge_edges` | Relaciones entre nodos | E- |
| `goals` | Objetivos/OKRs | G- |

## Sistema de Memoria

Decodifico tu shorthand laboral usando la tabla `knowledge_nodes`:

```
Usuario: "pedile a todd el PSR de oracle"
              ↓ Busco en knowledge_nodes
"Pedir a Todd Martinez (Finance lead) el Pipeline Status Report"
```

### knowledge_nodes

| Campo | Uso |
|-------|-----|
| `name` | Nombre principal |
| `node_type` | 'person', 'term', 'project', 'tool', 'context' |
| `aliases` | JSON array de apodos/nicknames |
| `description` | Descripción completa |
| `importance` | 0.0-1.0, frecuencia de uso |

### Lookup Flow

```
1. Match exacto por name           → "Todd Martinez"
2. Match por aliases (JSON contains) → "Todd", "T", "toddmart"
3. FTS5 en name + description      → búsqueda textual
4. Si no existe → preguntar al usuario y guardar
```

### Gestión

**Aprender:**
```
recordá que "phoenix" es el proyecto de migración de DB
→ INSERT INTO knowledge_nodes (node_type='project', name='phoenix', description='...')

aprendé que "Todd" es Todd Martinez de Finance
→ INSERT INTO knowledge_nodes (node_type='person', name='Todd Martinez', aliases='["Todd","T"]')
```

**Consultar:**
```
quién es todd → busca por aliases en knowledge_nodes
qué significa PSR → busca por name o FTS5
```

## Formato de Tareas

Las tareas se guardan en SQLite. Se presentan así:

```
- [ ] **Título en bold** — contexto, para quién, due: fecha
- [x] ~~Título completado~~ (2026-05-16)
```

Convenciones:
- **Bold** el título
- "para [persona]" si es compromiso con alguien
- "due: [fecha]" para deadlines

## Comandos

### tareas pendientes
Muestra compromisos activos ordenados por prioridad.

```
C-0012 Actualizar módulos de terraform          alta    vie
C-0010 Revisar PR de infra                      media   lun
```

### hoy / eventos / qué tengo
Combina calendario + compromisos con vencimiento hoy.

> ⚠️ **Siempre consultar AMBOS calendarios**: `alejandro.schwartzmann@allaria.com.ar` (Allaria) y `alejandro.schwartzmann@almafintech.com.ar` (AlmaFintech). Usar `calendarId` con un array de ambos.

```
jueves 14/5
  10:00 Standup semanal
  14:00 Review con equipo
  Pendiente: Actualizar módulos de terraform
```

### task "..."
Captura un compromiso al instante:

```
task "actualizar módulos de terraform"
> Capturado C-0013 | alta | esta semana
```

### completo / cancel / patea / arranco
Actualizan el estado de un compromiso:
- **completo C-XXXX** → `completed`
- **cancelo C-XXXX** → `cancelled`
- **arranco C-XXXX** → `in_progress`
- **patea C-XXXX** → modifica due_date

### recordá que / aprendé que
Guarda conocimiento en `knowledge_nodes`.

### quién es / qué significa
Busca en `knowledge_nodes` por name o aliases.

### revisar
Triage: tareas vencidas, gaps en memoria, limpieza.

## MCP integrado

| MCP | Tools | Para qué |
|-----|-------|----------|
| `google-calendar` | list-events, get-freebusy, create-event, search-events | Calendario |
| `jira` | createJiraIssue, editJiraIssue, transitionJiraIssue, searchJiraIssuesUsingJql, … | Jira/Confluence |

Se usa automáticamente cuando preguntás por tu día.

> ⚠️ **Siempre consultar AMBOS calendarios**: pasar `calendarId` como array con los IDs de los dos calendarios principales (`alejandro.schwartzmann@allaria.com.ar` y `alejandro.schwartzmann@almafintech.com.ar`) para no perder eventos.

## Jira: bug del MCP y workarounds

El MCP de Atlassian (vía opencode) tiene un bug persistente: cuando se llama a `editJiraIssue` o `createJiraIssue` pasando `fields`/`additional_fields` con ciertos contenidos (custom fields primitivos como integer/float, ej. SP `customfield_10016` o Sprint `customfield_10020`), el wrapper serializa el objeto a string antes de enviarlo, y la validación del server lo rechaza con:

```
Expected object, received string at path ["fields"]
```

**No es del lado del schema ni de Jira** — es la serialización del cliente.

**Workaround:** dos scripts bundleados que llaman la REST API v3 directamente vía curl, usando el access token cacheado del MCP.

### Script 1: `set-jira-fields.sh` (genérico)

Setea cualquier conjunto de campos en un ticket existente vía PUT.

```bash
~/.config/opencode/skills/secretary/scripts/set-jira-fields.sh <issueKey> '<json-fields-object>'
```

Ejemplos:

```bash
# Setear labels + epic + SP + sprint en una sola llamada
set-jira-fields.sh DP-18128 '{"labels":["platform"],"customfield_10016":1.5,"customfield_10020":1349,"parent":{"key":"DP-16496"}}'

# Solo labels
set-jira-fields.sh DP-18128 '{"labels":["platform"]}'
```

### Script 2: `move-to-sprint.sh` (atajo para sprint)

Mueve uno o varios tickets a un sprint en una llamada.

```bash
~/.config/opencode/skills/secretary/scripts/move-to-sprint.sh <sprintId> <issueKey> [<issueKey> ...]
```

Ejemplos:

```bash
# Un ticket
move-to-sprint.sh 1349 DP-18121

# Varios
move-to-sprint.sh 1349 DP-18121 DP-18122 DP-18123
```

Ambos leen el token de `~/.local/share/opencode/mcp-auth.json`. No requieren setup.

### Patrón recomendado al crear tickets

1. `createJiraIssue` (MCP) con **solo** `summary`, `issueTypeName`, `projectKey`, `assignee_account_id`, `description`. **No** usar `additional_fields`.
2. Capturar el `key` devuelto (ej. `DP-18128`).
3. Llamar `set-jira-fields.sh DP-18128 '{"labels":["platform"],"customfield_10016":1.5,"customfield_10020":<sprintId>,"parent":{"key":"<EPIC>"}}'`.
4. Si hay que transitionarlo (ej. crear con status Done), usar `transitionJiraIssue` del MCP — eso sí funciona.

### Custom field IDs en Allaria (proyecto DP)

| Campo | ID |
|---|---|
| Story Points | `customfield_10016` |
| Sprint | `customfield_10020` |

### Cómo encontrar el sprint ID

JQL para inspeccionar:

```jql
sprint in openSprints() AND project = DP
sprint in futureSprints() AND project = DP
```

El campo `customfield_10020[0].id` de la respuesta es el `sprintId` numérico (ej. `1349` para "Sprint 77" en board 2 de Allaria).

### Defaults Allaria

- **Cloud ID:** `91fb92aa-9455-4234-becd-7c1d232cdb46`
- **Project key:** `DP`
- **Board 2 (Allaria Project):** sprint activo se rota con frecuencia, chequear con JQL antes
- **Mi accountId:** `712020:a803ac7d-3236-4e54-afb9-0e280a3e0a19` (Alejandro Schwartzmann)
- **Convenciones:** todo ticket que cree va con `labels: ["platform"]` y assignee a mí (después yo lo reasigno al equipo)
- **Épicas frecuentes:** DP-11577 (Market Data), DP-16044 (Plataforma research – Market Data), DP-16496 (Sav3), DP-1312 (Infrastructure improvements), DP-2922 (Deuda técnica BACK)

## Mantenimiento

Decime directamente:
- "completo C-0012"
- "cancelo C-0010"
- "patea C-0015 para la semana que viene"
- "recordá que X es Y"
- "olvidate de N-0010" (borra un knowledge node)
- "revisar" (triage completo)
