#!/bin/bash
# =============================================================================
# Secretary Skill - Database Initialization for OpenCode
# =============================================================================
# Run this script once to set up the secretary database for use with OpenCode.
# Usage: bash ~/.config/opencode/skills/init-secretary.sh
# =============================================================================

set -e

SECRETARY_DIR="$HOME/.config/opencode/secretary"
DB_PATH="$SECRETARY_DIR/secretary.db"

echo "🔧 Initializing Secretary database for OpenCode..."
echo "  Directory: $SECRETARY_DIR"
echo "  Database:  $DB_PATH"
echo ""

# Create directory
mkdir -p "$SECRETARY_DIR"

# Check if sqlite3 is available
if ! command -v sqlite3 &> /dev/null; then
    echo "❌ sqlite3 not found. Install it first:"
    echo "  macOS: brew install sqlite3"
    echo "  Linux: sudo apt-get install sqlite3"
    exit 1
fi

# Create database (will fail gracefully if already exists)
if [ -f "$DB_PATH" ]; then
    echo "⚠️  Database already exists at $DB_PATH"
    read -p "  Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "❌ Aborted."
        exit 0
    fi
    rm "$DB_PATH"
fi

sqlite3 "$DB_PATH" <<'SQL'
-- ============================================================================
-- Core Tables
-- ============================================================================

CREATE TABLE commitments (
    id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT,
    source_type TEXT, source_session_id TEXT, source_context TEXT,
    project TEXT, assignee TEXT, stakeholder TEXT,
    due_date TEXT, due_type TEXT, priority TEXT DEFAULT 'medium',
    status TEXT DEFAULT 'pending',
    deferred_count INTEGER DEFAULT 0, deferred_until TEXT, completed_at TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE decisions (
    id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT,
    rationale TEXT, alternatives TEXT, consequences TEXT,
    category TEXT, scope TEXT, project TEXT,
    source_session_id TEXT, source_context TEXT,
    status TEXT DEFAULT 'active', superseded_by TEXT, tags TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE ideas (
    id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT,
    idea_type TEXT, category TEXT, project TEXT,
    source_session_id TEXT, source_context TEXT,
    priority TEXT, effort TEXT, potential_impact TEXT,
    status TEXT DEFAULT 'captured', tags TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE goals (
    id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT,
    goal_type TEXT, timeframe TEXT, parent_goal_id TEXT, project TEXT,
    target_value REAL, target_unit TEXT, current_value REAL DEFAULT 0,
    progress_percentage REAL DEFAULT 0, target_date TEXT, status TEXT DEFAULT 'active',
    milestones TEXT, related_commitments TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE sessions (
    id TEXT PRIMARY KEY, project TEXT, branch TEXT, summary TEXT,
    started_at TEXT, ended_at TEXT, duration_seconds INTEGER, status TEXT,
    commit_count INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE activity_timeline (
    id INTEGER PRIMARY KEY AUTOINCREMENT, activity_type TEXT,
    entity_type TEXT, entity_id TEXT, project TEXT, title TEXT,
    details TEXT, session_id TEXT, created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE knowledge_nodes (
    id TEXT PRIMARY KEY, name TEXT NOT NULL, node_type TEXT,
    description TEXT, properties TEXT, aliases TEXT,
    importance REAL DEFAULT 0.5, interaction_count INTEGER DEFAULT 0,
    last_interaction TEXT, created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE knowledge_edges (
    id TEXT PRIMARY KEY, source_node_id TEXT NOT NULL,
    target_node_id TEXT NOT NULL, relationship TEXT NOT NULL,
    strength REAL DEFAULT 0.5, properties TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE daily_notes (
    id TEXT PRIMARY KEY, date TEXT UNIQUE,
    sessions_count INTEGER DEFAULT 0, last_activity_at TEXT,
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE patterns (
    id TEXT PRIMARY KEY, title TEXT, pattern_type TEXT, category TEXT,
    description TEXT, confidence REAL, evidence_count INTEGER DEFAULT 0,
    recommendations TEXT, frequency TEXT, status TEXT DEFAULT 'active',
    created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT, event_type TEXT, payload TEXT,
    status TEXT DEFAULT 'pending', retry_count INTEGER DEFAULT 0, error TEXT,
    created_at TEXT DEFAULT (datetime('now')), processed_at TEXT
);

CREATE TABLE worker_state (
    id INTEGER PRIMARY KEY CHECK (id = 1), last_run_at TEXT,
    last_success_at TEXT, last_error TEXT, items_processed INTEGER DEFAULT 0,
    total_runs INTEGER DEFAULT 0, last_vault_sync_at TEXT,
    last_github_refresh_at TEXT, created_at TEXT DEFAULT (datetime('now'))
);
INSERT INTO worker_state (id, total_runs) VALUES (1, 0);

-- FTS5
CREATE VIRTUAL TABLE IF NOT EXISTS commitments_fts USING fts5(title, description, content=commitments, content_rowid=rowid);
CREATE VIRTUAL TABLE IF NOT EXISTS decisions_fts USING fts5(title, description, rationale, content=decisions, content_rowid=rowid);
CREATE VIRTUAL TABLE IF NOT EXISTS ideas_fts USING fts5(title, description, content=ideas, content_rowid=rowid);
CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_nodes_fts USING fts5(name, description, content=knowledge_nodes, content_rowid=rowid);

-- FTS triggers
CREATE TRIGGER commitments_ai AFTER INSERT ON commitments BEGIN
    INSERT INTO commitments_fts(rowid, title, description) VALUES (new.rowid, new.title, new.description); END;
CREATE TRIGGER commitments_ad AFTER DELETE ON commitments BEGIN
    INSERT INTO commitments_fts(commitments_fts, rowid, title, description) VALUES('delete', old.rowid, old.title, old.description); END;
CREATE TRIGGER commitments_au AFTER UPDATE ON commitments BEGIN
    INSERT INTO commitments_fts(commitments_fts, rowid, title, description) VALUES('delete', old.rowid, old.title, old.description);
    INSERT INTO commitments_fts(rowid, title, description) VALUES (new.rowid, new.title, new.description); END;
CREATE TRIGGER decisions_ai AFTER INSERT ON decisions BEGIN
    INSERT INTO decisions_fts(rowid, title, description, rationale) VALUES (new.rowid, new.title, new.description, new.rationale); END;
CREATE TRIGGER decisions_ad AFTER DELETE ON decisions BEGIN
    INSERT INTO decisions_fts(decisions_fts, rowid, title, description, rationale) VALUES('delete', old.rowid, old.title, old.description, old.rationale); END;
CREATE TRIGGER decisions_au AFTER UPDATE ON decisions BEGIN
    INSERT INTO decisions_fts(decisions_fts, rowid, title, description, rationale) VALUES('delete', old.rowid, old.title, old.description, old.rationale);
    INSERT INTO decisions_fts(rowid, title, description, rationale) VALUES (new.rowid, new.title, new.description, new.rationale); END;

-- Indexes
CREATE INDEX idx_commitments_status ON commitments(status);
CREATE INDEX idx_commitments_project ON commitments(project);
CREATE INDEX idx_commitments_due_date ON commitments(due_date);
CREATE INDEX idx_decisions_status ON decisions(status);
CREATE INDEX idx_decisions_project ON decisions(project);
CREATE INDEX idx_ideas_status ON ideas(status);
CREATE INDEX idx_goals_status ON goals(status);
CREATE INDEX idx_sessions_project ON sessions(project);
CREATE INDEX idx_sessions_started ON sessions(started_at);
CREATE INDEX idx_activity_timeline_type ON activity_timeline(activity_type);
CREATE INDEX idx_activity_timeline_created ON activity_timeline(created_at);
CREATE INDEX idx_knowledge_nodes_type ON knowledge_nodes(node_type);
CREATE INDEX idx_knowledge_edges_relationship ON knowledge_edges(relationship);
CREATE INDEX idx_queue_status ON queue(status);

PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
PRAGMA cache_size=-64000;
PRAGMA foreign_keys=ON;
SQL

echo ""
echo "✅ Database initialized at: $DB_PATH"
echo "  Tables: commitments, decisions, ideas, goals, sessions,"
echo "          activity_timeline, knowledge_nodes, knowledge_edges,"
echo "          daily_notes, patterns, queue"
echo ""
