---
name: assistant
description: Context-aware briefings, memory recall, strategic analysis, and work prioritization across sessions. Use when starting a session, recalling past decisions, checking pending work, prioritizing, or reviewing productivity trends.
license: MIT
compatibility: opencode
---

# Assistant Skill

Briefings, memory recall, knowledge graph, and strategic analysis — todo sobre el mismo DB de secretary.

Queries de recall/briefing: `reference/queries.md`  
Queries estratégicas: `reference/queries-strategic.md`

## Cuándo usar

**Modo briefing / recall:**
- "¿Qué tengo pendiente?" / "¿Qué debería hacer?"
- "¿Qué decidí sobre X?" / "Recordame..."
- Inicio de sesión — generar briefing de contexto
- Buscar en todo el conocimiento capturado
- Explorar el knowledge graph

**Modo análisis estratégico:**
- "¿Qué es más importante?" / "¿En qué me enfoco?"
- "¿Cómo estoy yendo?" / "¿Qué tan productivo fui?"
- Review semanal o mensual
- Detectar cuellos de botella o items estancados
- Evaluar progreso de goals y riesgo

## Briefing & Recall

Secuencia para un briefing: Pending Commitments → Recent Decisions → Goal Progress → Ideas Inbox → Queue Status.

Para recall: FTS5 search en decisions/commitments/ideas/knowledge_nodes. Fallback a LIKE. Revisar también Session History.

Para contexto de proyecto: sessions recientes + decisions activas + commitments pendientes filtrado por `:current_project`.

Para knowledge graph: Entity Relationships o All Connections.

## Análisis Estratégico

### Framework de priorización

Score = urgency (0–100) + priority_weight (0–40) + stakeholder_factor (0–20) + deferral_penalty (–10/deferral).

### Eisenhower Matrix

```
URGENT + IMPORTANT      → Hacer ahora
NOT URGENT + IMPORTANT  → Agendar
URGENT + NOT IMPORTANT  → Delegar
NOT URGENT + NOT IMPORTANT → Eliminar
```

### Qué analizar según la pregunta

| Pregunta | Queries a correr |
|----------|-----------------|
| ¿Qué hago ahora? | Priority Scoring |
| ¿Cómo estoy yendo? | Session Metrics + Completion Rates + Time Distribution |
| ¿Los goals van bien? | Goal Velocity |
| ¿Qué está trabado? | Long-Pending + Frequently Deferred + Stale In-Progress |

## Formatos de output

### Briefing

```markdown
# Briefing — {fecha}

## Atención requerida
### Vencidos
- [C-0001] Fix bug — 2 días vencido
### Hoy
- [C-0003] Review PR

## Contexto
### Decisiones recientes
- [D-0015] Usar Redis para cache
### Goals activos
- [G-0001] MVP Launch [=========-] 90%
### Ideas inbox
- [I-0010] Migración GraphQL (exploración)
```

### Recall

```markdown
# Recall: "{query}"

## Decisiones (3)
- [D-0015] Usar Redis — Rationale: mejor performance, TTL nativo

## Compromisos (1)
- [C-0030] Implementar caching layer — In Progress

## Ideas (1)
- [I-0008] Cache warming on deploy — Captured
```

### Priority Report

```markdown
# Prioridades

## Hacer hoy
1. **[C-0001] Fix auth bug** — Vencido, crítico. Stakeholder: Product
2. **[C-0003] Review PR** — Vence hoy

## Agendar esta semana
3. **[G-0002] API integration** — Goal en riesgo (60%), necesita +8%/día

## Considerar eliminar
- [C-0010] Research task — 3x diferido, bajo impacto
```

### Review estratégico

```markdown
# Review semanal

## Métricas
| Métrica | Esta semana | Tendencia |
|---------|-------------|-----------|
| Sesiones | 18 | +20% |
| Horas | 24h | +15% |
| Completados | 11 | +37% |

## Preocupaciones
1. Carryover creciendo — 8 items >2 semanas
2. Goal G-0003 en riesgo

## Recomendaciones
1. Limpiar backlog mañana (2h)
2. Sprint de documentación miércoles
```

## Error Handling

- DB no existe: "Secretary database not initialized."
- Sin resultados: "No matching records found for: {query}"
- Datos escasos: dar recomendaciones default y aclarar que hay pocos datos
