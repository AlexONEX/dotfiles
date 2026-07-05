---
name: db-connect
description: Connect to Allaria production databases via VPN using AWS Secrets Manager + mysql CLI. Use when the user wants to query production databases read-only, inspect schemas, look up prices, or debug data issues.
argument-hint: <secret-name or db-host> <profile>
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob", "Edit", "WebSearch", "WebFetch", "Task", "TodoWrite"]
---

# DB Connect — Allaria Production

## Prerequisites

- **VPN** activo y ruteando (ruta a `10.20.0.0/16` debe existir)
- **AWS CLI** con perfil `production` configurado
- **mysql CLI** instalado

## Database inventory (production)

| DB | Host | Secret (Secrets Manager) |
|----|------|--------------------------|
| market-data | `marketdata.db.internal.allaria.cloud` | `application/market-data` |
| *(add more as discovered)* | | |

## Workflow

### 1. Obtener credenciales

```bash
rtk aws secretsmanager get-secret-value --secret-id <secret-name> --profile production --query SecretString --output text
```

El secreto contiene `db_username`, `db_password`, `db_database`.

### 2. Conectar

```bash
mysql -h <host> -u <user> -p'<password>' <database> -e "<query>"
```

### 3. Reglas

- **READ-ONLY siempre** — solo `SELECT`, `DESCRIBE`, `SHOW TABLES`
- **Pedir confirmación** por cada comando `mysql` antes de ejecutar
- No hardcodear credenciales en ningún archivo — siempre leer del secreto
- Usar `--connect-timeout=10` para timeout rápido si el VPN está caído

## Troubleshooting

### "Can't connect — Operation timed out"

**Causa probable**: El security group de la RDS no permite tu IP de VPN.

Verificar ruta:
```bash
route -n get 10.20.180.62
# debería mostrar interface: utun7 (o la interfaz VPN)
```

Verificar IP asignada por VPN:
```bash
ifconfig utun7 | grep "inet "
```

Security groups habilitados (producción):
| DB | Security Group | IPs permitidas |
|----|---------------|----------------|
| market-data | `marketdata-db-sg` | `172.20.0.0/21`, `172.23.6.0/24`, `10.20.0.0/16` |

Si tu IP de VPN no está en rango permitido, pedir a infra que agregue el rango.

### Solución alternativa: SSM tunnel

Si el VPN no funciona, se puede usar SSM port forwarding a través de la EC2 bastión:

```bash
# Instalar session-manager-plugin primero
# Luego:
aws ssm start-session --target <instance-id> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["<db-host>"],"portNumber":["3306"],"localPortNumber":["3307"]}' \
  --profile production

# Conectar por el tunnel local:
mysql -h 127.0.0.1 -P 3307 -u <user> -p'<password>' <database>
```

### Solución alternativa: CloudShell

Desde la consola AWS web, abrir CloudShell (está dentro de la VPC) y ejecutar `mysql` directo.

## BYMA dump local

Hay un dump BYMA en `/Users/alex/.config/opencode/output.json` (~1242 símbolos). Útil para buscar símbolos que no están en la DB.

```bash
grep -o '"symbol": "[A-Z0-9 ]*"' /Users/alex/.config/opencode/output.json | sort -u
```
