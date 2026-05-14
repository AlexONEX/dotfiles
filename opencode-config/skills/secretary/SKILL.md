---
name: secretary
description: Capture and manage decisions, commitments, ideas, sessions, and knowledge. Use when tracking action items, recording decisions, capturing ideas, or managing project context across multiple sessions.
license: MIT
compatibility: opencode
---

# Secretary Skill

Capture commitments, record decisions, track ideas, manage sessions, and maintain a personal knowledge base across your OpenCode sessions.

## When to Use

- Analyzing conversation for commitments, decisions, or ideas
- Recording a new commitment, decision, or idea manually
- Updating the status of a tracked item (complete, defer, cancel)
- Managing queue items and worker processing
- Updating the knowledge graph
- Managing goals and milestones
- Accessing or managing encrypted memory entries
- Checking worker and queue status

## Database Locations

```bash
# Main database
SECRETARY_DB_PATH="$HOME/.config/opencode/secretary/secretary.db"

# Encrypted memory database
SECRETARY_MEMORY_DB_PATH="$HOME/.config/opencode/secretary/memory.db"

# Configuration
SECRETARY_CONFIG_FILE="$HOME/.config/opencode/secretary.json"

# Scripts directory (if deployed)
PLUGIN_ROOT="$HOME/.config/opencode/secretary"
```

## Setup

Before first use, run these to initialize:

```bash
# Create directories
mkdir -p "$HOME/.config/opencode/secretary"

# Create main database
sqlite3 "$HOME/.config/opencode/secretary/secretary.db" "
  CREATE TABLE IF NOT EXISTS commitments (
    id TEXT PRIMARY KEY, title TEXT, description TEXT,
    source_type TEXT, source_session_id TEXT, source_context TEXT,
    project TEXT, assignee TEXT, stakeholder TEXT,
    due_date TEXT, due_type TEXT, priority TEXT,
    status TEXT DEFAULT 'pending',
    deferred_count INTEGER DEFAULT 0, deferred_until TEXT,
    completed_at TEXT, created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS decisions (
    id TEXT PRIMARY KEY, title TEXT, description TEXT,
    rationale TEXT, alternatives TEXT, consequences TEXT,
    category TEXT, scope TEXT, project TEXT,
    source_session_id TEXT, source_context TEXT,
    status TEXT DEFAULT 'active',
    superseded_by TEXT, tags TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS ideas (
    id TEXT PRIMARY KEY, title TEXT, description TEXT,
    idea_type TEXT, category TEXT, project TEXT,
    source_session_id TEXT, source_context TEXT,
    priority TEXT, effort TEXT, potential_impact TEXT,
    status TEXT DEFAULT 'captured', tags TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS goals (
    id TEXT PRIMARY KEY, title TEXT, description TEXT,
    goal_type TEXT, timeframe TEXT, parent_goal_id TEXT,
    project TEXT, target_value REAL, target_unit TEXT,
    current_value REAL DEFAULT 0, progress_percentage REAL DEFAULT 0,
    target_date TEXT, status TEXT DEFAULT 'active',
    milestones TEXT, related_commitments TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY, project TEXT, branch TEXT,
    summary TEXT, started_at TEXT, ended_at TEXT,
    duration_seconds INTEGER, status TEXT,
    commit_count INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS activity_timeline (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    activity_type TEXT, entity_type TEXT, entity_id TEXT,
    project TEXT, title TEXT, details TEXT,
    session_id TEXT, created_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS knowledge_nodes (
    id TEXT PRIMARY KEY, name TEXT, node_type TEXT,
    description TEXT, properties TEXT, aliases TEXT,
    importance REAL DEFAULT 0.5, interaction_count INTEGER DEFAULT 0,
    last_interaction TEXT, created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS knowledge_edges (
    id TEXT PRIMARY KEY, source_node_id TEXT,
    target_node_id TEXT, relationship TEXT,
    strength REAL DEFAULT 0.5, properties TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS daily_notes (
    id TEXT PRIMARY KEY, date TEXT UNIQUE,
    sessions_count INTEGER DEFAULT 0,
    last_activity_at TEXT, created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS patterns (
    id TEXT PRIMARY KEY, title TEXT, pattern_type TEXT,
    category TEXT, description TEXT, confidence REAL,
    evidence_count INTEGER DEFAULT 0, recommendations TEXT,
    frequency TEXT, status TEXT DEFAULT 'active',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );
  CREATE TABLE IF NOT EXISTS queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT, payload TEXT, status TEXT DEFAULT 'pending',
    retry_count INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now')),
    processed_at TEXT
  );
"
```

## Commitment Management

### Recording a Commitment

```sql
-- Get next ID
SELECT 'C-' || printf('%04d', COALESCE(MAX(CAST(SUBSTR(id, 3) AS INTEGER)), 0) + 1) as next_id
FROM commitments;

-- Insert
INSERT INTO commitments (
    id, title, description, source_type, source_session_id,
    source_context, project, assignee, stakeholder,
    due_date, due_type, priority, status
) VALUES (
    :id, :title, :description, :source_type, :session_id,
    :context, :project, :assignee, :stakeholder,
    :due_date, :due_type, :priority, 'pending'
);
```

### Updating Commitments

```sql
-- Complete
UPDATE commitments SET
    status = 'completed', completed_at = datetime('now'), updated_at = datetime('now')
WHERE id = :id;

-- Defer
UPDATE commitments SET
    status = 'deferred', deferred_until = :date,
    deferred_count = deferred_count + 1, updated_at = datetime('now')
WHERE id = :id;

-- Cancel
UPDATE commitments SET
    status = 'canceled', updated_at = datetime('now')
WHERE id = :id;
```

### Listing Commitments

```sql
-- All pending (sorted by priority and urgency)
SELECT id, title, due_date, priority, project, status
FROM commitments
WHERE status IN ('pending', 'in_progress')
ORDER BY
    CASE WHEN due_date < date('now') THEN 0 ELSE 1 END,
    CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END,
    due_date ASC;
```

### Detection Patterns

Look for these phrases in conversation:

**Commitments:**
- "I will...", "I'll...", "Let me..."
- "We should...", "We need to..."
- "TODO:", "FIXME:", "Follow up on..."
- "Don't forget to...", "Make sure to..."
- "Remind me to...", "Get back to..."

## Decision Recording

### Recording a Decision

```sql
-- Get next ID
SELECT 'D-' || printf('%04d', COALESCE(MAX(CAST(SUBSTR(id, 3) AS INTEGER)), 0) + 1) as next_id
FROM decisions;

-- Insert
INSERT INTO decisions (
    id, title, description, rationale, alternatives,
    consequences, category, scope, project,
    source_session_id, source_context, status, tags
) VALUES (
    :id, :title, :description, :rationale, :alternatives_json,
    :consequences, :category, :scope, :project,
    :session_id, :context, 'active', :tags_json
);
```

### Detection Patterns

**Decisions:**
- "Decided to...", "The decision is..."
- "Let's go with...", "We'll use..."
- "The approach is...", "The plan is..."
- "From now on...", "Going forward..."
- "Instead of...", "Rather than..."

## Idea Capture

### Recording an Idea

```sql
-- Get next ID
SELECT 'I-' || printf('%04d', COALESCE(MAX(CAST(SUBSTR(id, 3) AS INTEGER)), 0) + 1) as next_id
FROM ideas;

-- Insert
INSERT INTO ideas (
    id, title, description, idea_type, category,
    project, source_session_id, source_context,
    priority, effort, potential_impact, status, tags
) VALUES (
    :id, :title, :description, :type, :category,
    :project, :session_id, :context,
    :priority, :effort, :impact, 'captured', :tags_json
);
```

## Goal Management

### Creating a Goal

```sql
SELECT 'G-' || printf('%04d', COALESCE(MAX(CAST(SUBSTR(id, 3) AS INTEGER)), 0) + 1) as next_id
FROM goals;

INSERT INTO goals (
    id, title, description, goal_type, timeframe,
    parent_goal_id, project, target_value, target_unit,
    target_date, status, milestones, related_commitments
) VALUES (
    :id, :title, :description, :type, :timeframe,
    :parent_id, :project, :target_value, :target_unit,
    :target_date, 'active', :milestones_json, :related_json
);
```

## Knowledge Graph

### Node Types

| Type | Description |
|------|-------------|
| `project` | Software projects |
| `technology` | Languages, frameworks, tools |
| `person` | Team members, stakeholders |
| `concept` | Architectural patterns, methodologies |
| `tool` | Development tools, services |

### Creating/Updating Nodes

```sql
SELECT 'N-' || printf('%04d', COALESCE(MAX(CAST(SUBSTR(id, 3) AS INTEGER)), 0) + 1) as next_id
FROM knowledge_nodes;

INSERT INTO knowledge_nodes (id, name, node_type, description, properties, aliases)
VALUES (:id, :name, :type, :description, :properties_json, :aliases_json)
ON CONFLICT(id) DO UPDATE SET
    description = COALESCE(:description, description),
    interaction_count = interaction_count + 1,
    last_interaction = datetime('now'),
    updated_at = datetime('now');
```

### Relationship Types

- `uses` - Project uses technology
- `knows` - Person knows technology
- `owns` - Person owns project
- `depends_on` - Project depends on another
- `related_to` - General relationship

## Activity Timeline

```sql
INSERT INTO activity_timeline (
    activity_type, entity_type, entity_id,
    project, title, details, session_id
) VALUES (:type, :entity_type, :entity_id, :project, :title, :details_json, :session_id);
```

## Output Guidelines

When reporting captured items:

```markdown
## Captured

### Commitment
- **ID:** C-0025
- **Title:** Implement caching layer
- **Priority:** High
- **Due:** This week
- **Source:** Conversation

### Decision
- **ID:** D-0018
- **Title:** Use Redis for caching
- **Category:** Architecture
- **Rationale:** Better performance for distributed systems

### Idea
- **ID:** I-0015
- **Title:** GraphQL migration
- **Type:** Exploration
- **Impact:** High
```

## Manual Capture Workflow (No Hooks)

Since OpenCode doesn't have Claude Code's hook system, you won't get automatic capture. Use this workflow instead:

1. **At the end of each session**, ask me to scan the conversation for:
   - Commitments made ("I will...", "Let me...")
   - Decisions reached ("We decided to...")
   - Ideas generated ("What if...")
2. **I'll extract these and write them to the database**
3. **Run a status check** to review all tracked items

Suggested prompt: "Review this session and capture any commitments, decisions, or ideas"

## ID Generation Pattern

```
C-0001 for commitments
D-0001 for decisions
I-0001 for ideas
G-0001 for goals
P-0001 for patterns
N-0001 for knowledge nodes
E-0001 for knowledge edges
```

## Error Handling

- Skip malformed or ambiguous items during extraction
- Continue processing on individual item failures
- Note if the database hasn't been initialized yet

## Related Commands

- Track commitments (add, complete, defer, list)
- Record decisions with rationale
- Capture ideas
- Show full status dashboard
- Generate context briefing
- Manage encrypted memory
