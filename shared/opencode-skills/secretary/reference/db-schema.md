# Secretary DB Schema

```bash
DB="$HOME/.config/opencode/secretary/secretary.db"
```

## Tablas

| Tabla | Guarda | ID prefix |
|-------|--------|-----------|
| `commitments` | Compromisos/tareas | C- |
| `decisions` | Decisiones tomadas | D- |
| `ideas` | Ideas capturadas | I- |
| `knowledge_nodes` | Personas, términos, proyectos | N- |
| `knowledge_edges` | Relaciones entre nodos | E- |
| `goals` | Objetivos/OKRs | G- |

## knowledge_nodes

| Campo | Uso |
|-------|-----|
| `name` | Nombre principal |
| `node_type` | 'person', 'term', 'project', 'tool', 'context' |
| `aliases` | JSON array de apodos/nicknames |
| `description` | Descripción completa |
| `importance` | 0.0-1.0, frecuencia de uso |

## Lookup flow

```
1. Match exacto por name
2. Match por aliases (JSON contains)
3. FTS5 en name + description
4. Si no existe → preguntar al usuario y guardar
```
