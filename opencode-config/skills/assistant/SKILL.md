---
name: assistant
description: Context-aware briefings, memory recall, knowledge graph queries, and intelligent recommendations across sessions. Use when you need to recall past decisions, check what's pending, or get project context.
license: MIT
compatibility: opencode
---

# Assistant Skill

Provide context-aware assistance, intelligent briefings, memory recall, and knowledge graph queries across your OpenCode sessions.

## When to Use

- User asks "What should I work on?" or "What do I have pending?"
- User asks "What did I decide about X?" or "Remind me about..."
- User wants context about current or past work
- Session just started and a briefing is needed
- User wants to search across all captured knowledge
- User needs cross-project awareness or related item discovery
- User asks about the status of tracked items
- User wants to explore the knowledge graph

## Database Locations

```bash
# Main database
SECRETARY_DB_PATH="$HOME/.config/opencode/secretary/secretary.db"

# Encrypted memory (sensitive data)
SECRETARY_MEMORY_DB_PATH="$HOME/.config/opencode/secretary/memory.db"
```

## Generate Briefing

Query and format a comprehensive briefing based on current context.

### 1. Pending Commitments

```sql
SELECT id, title, due_date, priority, project, status, stakeholder
FROM commitments
WHERE status IN ('pending', 'in_progress')
ORDER BY
    CASE WHEN due_date IS NOT NULL AND due_date < date('now') THEN 0
         WHEN due_date = date('now') THEN 1
         WHEN due_date IS NOT NULL THEN 2
         ELSE 3 END,
    CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END;
```

### 2. Recent Decisions (Project-Specific)

```sql
SELECT id, title, category, created_at
FROM decisions
WHERE status = 'active'
  AND (project = :current_project OR project IS NULL)
  AND created_at >= datetime('now', '-7 days')
ORDER BY created_at DESC LIMIT 5;
```

### 3. Goal Progress

```sql
SELECT id, title, progress_percentage, target_date, goal_type
FROM goals WHERE status = 'active'
ORDER BY
    CASE WHEN target_date IS NOT NULL THEN 0 ELSE 1 END,
    progress_percentage DESC
LIMIT 5;
```

### 4. Ideas Inbox

```sql
SELECT id, title, idea_type, priority
FROM ideas WHERE status = 'captured'
ORDER BY created_at DESC LIMIT 5;
```

### 5. Queue Status

```sql
SELECT COUNT(*) as pending FROM queue WHERE status = 'pending';
```

## Memory Recall

When the user asks about past work, search across all knowledge stores.

### FTS5 Search (if available)

```sql
-- Search decisions
SELECT d.id, d.title, d.description, d.rationale, d.category,
       d.project, d.created_at
FROM decisions d
JOIN decisions_fts ON decisions_fts.rowid = d.rowid
WHERE decisions_fts MATCH :query AND d.status = 'active'
ORDER BY rank LIMIT 10;

-- Search commitments
SELECT c.id, c.title, c.description, c.priority, c.status,
       c.project, c.created_at
FROM commitments c
JOIN commitments_fts ON commitments_fts.rowid = c.rowid
WHERE commitments_fts MATCH :query
ORDER BY rank LIMIT 10;

-- Search ideas
SELECT i.id, i.title, i.description, i.idea_type, i.status,
       i.project, i.created_at
FROM ideas i
JOIN ideas_fts ON ideas_fts.rowid = i.rowid
WHERE ideas_fts MATCH :query
ORDER BY rank LIMIT 10;

-- Search knowledge nodes
SELECT kn.id, kn.name, kn.node_type, kn.description, kn.importance
FROM knowledge_nodes kn
JOIN knowledge_nodes_fts ON knowledge_nodes_fts.rowid = kn.rowid
WHERE knowledge_nodes_fts MATCH :query
ORDER BY rank LIMIT 10;
```

### LIKE Fallback (always works)

```sql
SELECT id, title, description, rationale, category, project, created_at
FROM decisions
WHERE status = 'active'
  AND (title LIKE '%' || :query || '%'
       OR description LIKE '%' || :query || '%'
       OR rationale LIKE '%' || :query || '%')
ORDER BY created_at DESC LIMIT 10;
```

### Session History Search

```sql
SELECT id, project, started_at, summary, duration_seconds / 60 as minutes
FROM sessions
WHERE summary LIKE '%' || :query || '%'
ORDER BY started_at DESC LIMIT 5;
```

## Knowledge Graph Queries

### Find Entity Relationships

```sql
SELECT
    kn_target.name as related_entity,
    kn_target.node_type as entity_type,
    ke.relationship,
    ke.strength
FROM knowledge_edges ke
JOIN knowledge_nodes kn_target ON kn_target.id = ke.target_node_id
WHERE ke.source_node_id = :entity_id
ORDER BY ke.strength DESC;
```

### Find All Connections for an Entity

```sql
SELECT
    CASE WHEN ke.source_node_id = :entity_id THEN kn_t.name ELSE kn_s.name END as connected_to,
    CASE WHEN ke.source_node_id = :entity_id THEN kn_t.node_type ELSE kn_s.node_type END as type,
    ke.relationship,
    ke.strength
FROM knowledge_edges ke
JOIN knowledge_nodes kn_s ON kn_s.id = ke.source_node_id
JOIN knowledge_nodes kn_t ON kn_t.id = ke.target_node_id
WHERE ke.source_node_id = :entity_id OR ke.target_node_id = :entity_id
ORDER BY ke.strength DESC;
```

## Context Awareness

### Get Current Project Context

```sql
-- Recent sessions in this project
SELECT id, started_at, summary, branch, duration_seconds / 60 as minutes
FROM sessions
WHERE project = :current_project AND status = 'completed'
ORDER BY started_at DESC LIMIT 3;
```

### Project-Specific Items

```sql
-- Active decisions for this project
SELECT id, title, category FROM decisions
WHERE project = :project AND status = 'active'
ORDER BY created_at DESC LIMIT 10;

-- Pending commitments for this project
SELECT id, title, due_date, priority FROM commitments
WHERE project = :project AND status IN ('pending', 'in_progress')
ORDER BY priority DESC, due_date ASC;
```

## Status Dashboard

```sql
SELECT
    (SELECT COUNT(*) FROM commitments WHERE status IN ('pending', 'in_progress')) as pending_commitments,
    (SELECT COUNT(*) FROM commitments WHERE status = 'pending' AND due_date < date('now')) as overdue,
    (SELECT COUNT(*) FROM decisions WHERE status = 'active') as active_decisions,
    (SELECT COUNT(*) FROM ideas WHERE status = 'captured') as idea_inbox,
    (SELECT COUNT(*) FROM goals WHERE status = 'active') as active_goals,
    (SELECT COUNT(*) FROM sessions WHERE date(started_at) = date('now')) as sessions_today;
```

## Output Guidelines

### Briefing Format

```markdown
# Briefing

**Project:** {project} | **Date:** {date}

## Attention Needed

### Overdue
- [C-0001] Fix bug - 2 days overdue

### Due Today
- [C-0003] Review PR

## Context

### Recent Decisions (this project)
- [D-0015] Use Redis for caching

### Active Goals
- [G-0001] MVP Launch [=========-] 90%

### Ideas Inbox
- [I-0010] GraphQL migration (exploration)
```

### Memory Recall Format

```markdown
# Recall: "{query}"

## Decisions (3 found)
- [D-0015] Use Redis for caching
  Rationale: Better performance, built-in TTL

## Commitments (1 found)
- [C-0030] Implement caching layer - In Progress

## Ideas (1 found)
- [I-0008] Cache warming on deploy - Captured

## Related Sessions
- Jan 25: Caching discussion (45 min) - my-project
```

## Error Handling

- If database does not exist: "Secretary database not initialized. Run the setup SQL first."
- If no results: "No matching records found for: {query}"
- Handle empty datasets gracefully
- Provide default recommendations when data is sparse
