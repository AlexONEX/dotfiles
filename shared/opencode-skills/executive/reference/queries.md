# Executive SQL Queries

## DB Path

```bash
SECRETARY_DB_PATH="$HOME/.config/opencode/secretary/secretary.db"
```

## Priority Scoring

```sql
SELECT
    c.id, c.title, c.due_date, c.priority, c.project, c.stakeholder,
    CASE
        WHEN c.due_date < date('now') THEN 100
        WHEN c.due_date = date('now') THEN 80
        WHEN c.due_date <= date('now', '+2 days') THEN 60
        WHEN c.due_date <= date('now', '+7 days') THEN 40
        ELSE 20
    END as urgency,
    CASE c.priority
        WHEN 'critical' THEN 40 WHEN 'high' THEN 30 WHEN 'medium' THEN 20 ELSE 10
    END as priority_score,
    CASE WHEN c.stakeholder IS NOT NULL THEN 20 ELSE 0 END as stakeholder_score,
    -10 * c.deferred_count as deferral_penalty
FROM commitments c
WHERE c.status IN ('pending', 'in_progress')
ORDER BY (urgency + priority_score + stakeholder_score + deferral_penalty) DESC;
```

## Session Metrics (last 30 days)

```sql
SELECT
    date(started_at) as date,
    COUNT(*) as sessions,
    SUM(duration_seconds) / 3600.0 as hours,
    AVG(duration_seconds) / 60.0 as avg_minutes,
    COUNT(DISTINCT project) as projects
FROM sessions
WHERE started_at >= datetime('now', '-30 days') AND status = 'completed'
GROUP BY date(started_at)
ORDER BY date DESC;
```

## Completion Rates (last 90 days)

```sql
SELECT
    strftime('%Y-%W', created_at) as week,
    COUNT(*) as created,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
    ROUND(100.0 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / COUNT(*), 1) as rate,
    SUM(CASE WHEN status = 'deferred' THEN 1 ELSE 0 END) as deferred,
    SUM(CASE WHEN status = 'canceled' THEN 1 ELSE 0 END) as canceled
FROM commitments
WHERE created_at >= datetime('now', '-90 days')
GROUP BY week ORDER BY week DESC;
```

## Time Distribution (last 7 days)

```sql
SELECT
    project,
    SUM(duration_seconds) / 3600.0 as hours,
    ROUND(100.0 * SUM(duration_seconds) / (
        SELECT SUM(duration_seconds) FROM sessions
        WHERE started_at >= datetime('now', '-7 days') AND status = 'completed'
    ), 1) as percentage,
    COUNT(*) as sessions
FROM sessions
WHERE started_at >= datetime('now', '-7 days') AND status = 'completed'
GROUP BY project ORDER BY hours DESC;
```

## Goal Velocity

```sql
SELECT
    g.id, g.title, g.goal_type, g.progress_percentage,
    g.target_date, g.target_value, g.current_value, g.target_unit,
    ROUND(julianday(g.target_date) - julianday('now'), 0) as days_remaining,
    ROUND((100 - g.progress_percentage) / NULLIF(julianday(g.target_date) - julianday('now'), 0), 2) as required_daily,
    CASE
        WHEN g.target_date < date('now') AND g.progress_percentage < 100 THEN 'overdue'
        WHEN (100 - g.progress_percentage) / NULLIF(julianday(g.target_date) - julianday('now'), 0) > 5 THEN 'at_risk'
        WHEN (100 - g.progress_percentage) / NULLIF(julianday(g.target_date) - julianday('now'), 0) > 2 THEN 'needs_attention'
        ELSE 'on_track'
    END as risk_status
FROM goals g
WHERE g.status = 'active' AND g.target_date IS NOT NULL
ORDER BY days_remaining ASC;
```

## Bottleneck: Long-Pending

```sql
SELECT id, title, priority, project,
    ROUND(julianday('now') - julianday(created_at), 0) as days_pending
FROM commitments WHERE status = 'pending'
ORDER BY days_pending DESC LIMIT 10;
```

## Bottleneck: Frequently Deferred

```sql
SELECT id, title, deferred_count, priority, project
FROM commitments
WHERE deferred_count >= 2 AND status NOT IN ('completed', 'canceled')
ORDER BY deferred_count DESC;
```

## Bottleneck: Stale In-Progress

```sql
SELECT id, title, priority, project,
    ROUND(julianday('now') - julianday(updated_at), 0) as days_stale
FROM commitments
WHERE status = 'in_progress' AND updated_at < datetime('now', '-7 days')
ORDER BY days_stale DESC;
```
