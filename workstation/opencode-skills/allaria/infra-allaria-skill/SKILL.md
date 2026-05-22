---
name: infra-allaria
description: Create and manage Allaria infrastructure with Terraform modules — ECS, Lambda, RDS, Aurora, S3, CloudFront, SQS, Kinesis, Redis, Keycloak, DMS, and more
---

## What I do

Guide creation of Allaria infrastructure using Terraform modules. This is a **catalog** — I list what modules exist and when to use each one. For full details (all variables, examples, outputs), I always read the module's `README.md` directly.

## Module repository

All modules live at:

```
/Users/alex/Github/Allaria/infra-terraform-modules/<module-name>/
```

Each module has a `README.md` with complete documentation. **Always read it** before generating HCL for a module you're not deeply familiar with.

## Global conventions

### Source format
Every module uses the same source:
```hcl
source = "git@github.com:allaria-tech/infra-terraform-modules.git//<module-name>"
```

### Environments
| Env | Suffix | Domain |
|-----|--------|--------|
| Development | `dev` | `*.allaria.dev` / `*.allariaagro.dev` |
| Production | `cloud` | `*.allaria.cloud` / `*.allariaagro.cloud` |

### Teams
Infra modules often require `team_name`. Expected values: `platform`, `timba`, `pampa`, `fly`, `cocru`, `oompas`, `dumbo`, `agro`.

### DNS naming patterns
- ECS services: `<name>.svc.internal.allaria.{dev|cloud}`
- RDS instances: `<name>.db.internal.allaria.{dev|cloud}`
- Redis cache: `<name>.cache.internal.allaria.{dev|cloud}`
- Functions (internal ALB): `<name>.svc.internal.allaria.{dev|cloud}`
- Public APIs: `<name>.api.allaria.{dev|cloud}` or `api.allaria.{dev|cloud}/<path>`

### Secrets Manager
Database credentials stored at:
- Applications: `application/<application_name>`
- Functions: `function/<application_name>`
- RDS: `infra/<name>-db-credentials`

### Monitoring
CloudWatch alarms send to `infra-events-topic` SNS. All modules that create alarms use this topic.

---

## Module catalog

### Compute

#### `ecs`
Deploy containerized services on ECS Fargate with ALB, auto-scaling, health checks, and monitoring.
- **When to use**: Any API or backend service that needs to run continuously
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/ecs/README.md`

#### `ecs-preview`
Create ephemeral QA environments per Pull Request for backend services.
- **When to use**: Adding preview environments in GitHub Actions workflows
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/ecs-preview/README.md`

#### `function`
Deploy Lambda functions with triggers: EventBridge (cron), ALB (internal/public/B2B), SQS, S3, Kinesis.
- **When to use**: Serverless event-driven processing, scheduled jobs, lightweight APIs
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/function/README.md`

### Databases

#### `aurora-cluster`
Create Aurora MySQL clusters with reader/writer endpoints, auto-generated passwords, security groups, DNS, and alarms.
- **When to use**: Production databases requiring HA and automatic read scaling
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/aurora-cluster/README.md`

#### `rds-instance`
Deploy standalone RDS instances (PostgreSQL or MySQL) with backups, alarms, and security groups.
- **When to use**: Simple managed databases (prefer PostgreSQL)
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/rds-instance/README.md`

#### `mysql-db-setup`
Create MySQL databases, users, and store credentials in Secrets Manager (post-RDS provisioning).
- **When to use**: After an RDS/MySQL instance exists, to create application-specific databases and users
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/mysql-db-setup/README.md`

#### `redis-cache`
Deploy ElastiCache Redis clusters with CPU/memory/evictions/connections alarms and DNS.
- **When to use**: Caching, session storage, real-time data
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/redis-cache/README.md`

#### `dms-task`
Create DMS replication tasks for full-load, CDC, or combined migrations with filtering and transformations.
- **When to use**: Migrating databases to AWS or setting up ongoing replication
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/dms-task/README.md`

### Storage & CDN

#### `s3-bucket`
Create S3 buckets with optional static website hosting, CloudFront, CORS config, and SQS notifications.
- **When to use**: Object storage, static websites, file uploads, S3-triggered processing
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/s3-bucket/README.md`

#### `cloudfront`
Create CloudFront distributions with S3 origins, SSL, and optional Lambda@Edge auth.
- **When to use**: Standalone CDN + S3 static websites (use when s3-bucket's built-in CloudFront isn't enough, or you need Lambda@Edge)
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/cloudfront/README.md`

### Messaging & Streaming

#### `sqs`
Create SQS queues with DLQ, FIFO support, configurable retention, and CloudWatch alarms.
- **When to use**: Async processing, event-driven architectures, service decoupling
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/sqs/README.md`

#### `kinesis`
Create Kinesis Data Streams (on-demand or provisioned) with consumer lag monitoring.
- **When to use**: Real-time streaming, event processing pipelines, Lambda data sources
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/kinesis/README.md`

#### `cloudwatch-filter`
Create CloudWatch Log subscription filters forwarding matching events to `owl-guardian` Lambda.
- **When to use**: Forwarding ERROR logs (or any pattern) from CloudWatch to owl-guardian for alerting
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/cloudwatch-filter/README.md`

### Security & Auth

#### `keycloak`
Create Keycloak OIDC clients with role definitions, cross-client role assignments, and configurable token lifespan.
- **When to use**: Service-to-service authentication, OIDC client registration
- **Read more**: `/Users/alex/Github/Allaria/infra-terraform-modules/keycloak/README.md`

---

## Common cross-module patterns

| Use case | Modules involved |
|----------|-----------------|
| API + DB | `ecs` + `rds-instance` (or `aurora-cluster`) |
| Serverless processor | `function` + `sqs` (or `kinesis`) + `s3-bucket` |
| Static site | `s3-bucket` (with `create_static_web_page`) or `cloudfront` |
| Log monitoring | `ecs`/`function` + `cloudwatch-filter` |
| Data pipeline | `dms-task` → `kinesis` → `function` |
| Auth-protected API | `ecs`/`function` + `keycloak` |
| PR preview | `ecs` + `ecs-preview` |

## VPC & Networking

### VPC Architecture

Allaria uses a hub-and-spoke model. The **main VPC** per environment/region is `your-vpcs`. Each VPC has three subnet tiers:

| Tier | Internet access | Use case |
|------|----------------|----------|
| **public** | Direct via IGW | Load balancers, NAT Gateways, bastions |
| **private** | Outbound via NAT Gateway | Compute workloads (ECS, Lambda, EC2) |
| **data** | No direct internet | Databases (RDS, Aurora, Redis), internal data services |

### VPC Inventory

#### Development (`dev`)

| Region | VPC CIDR | Public subnets | Private subnets | Data subnets |
|--------|----------|---------------|----------------|-------------|
| `us-east-1` (Virginia) | `10.10.0.0/16` | `10.10.0.0/24`, `10.10.1.0/24`, `10.10.2.0/24`, `10.10.3.0/24` | `10.10.26.0/24`, `10.10.27.0/24`, `10.10.28.0/24`, `10.10.29.0/24` | `10.10.180.0/24`, `10.10.181.0/24`, `10.10.182.0/24` |
| `sa-east-1` (São Paulo) | `10.11.0.0/16` | `10.11.0.0/24`, `10.11.1.0/24`, `10.11.2.0/24` | `10.11.26.0/24`, `10.11.27.0/24`, `10.11.28.0/24` | `10.11.180.0/24`, `10.11.181.0/24`, `10.11.182.0/24` |

#### Production (`cloud`)

| Region | VPC CIDR | Public subnets | Private subnets | Data subnets |
|--------|----------|---------------|----------------|-------------|
| `us-east-1` (Virginia) | `10.20.0.0/16` | `10.20.0.0/24`, `10.20.1.0/24`, `10.20.2.0/24` | `10.20.26.0/24`, `10.20.27.0/24`, `10.20.28.0/24` | `10.20.180.0/24`, `10.20.181.0/24`, `10.20.182.0/24` |
| `sa-east-1` (São Paulo) | `10.21.0.0/16` | `10.21.0.0/24`, `10.21.1.0/24`, `10.21.2.0/24` | `10.21.26.0/24`, `10.21.27.0/24`, `10.21.28.0/24` | `10.21.180.0/24`, `10.21.181.0/24`, `10.21.182.0/24` |
| `us-east-2` (Ohio) | `10.22.0.0/16` | `10.22.0.0/24`, `10.22.1.0/24`, `10.22.2.0/24` | `10.22.26.0/24`, `10.22.27.0/24`, `10.22.28.0/24` | `10.22.180.0/24`, `10.22.181.0/24`, `10.22.182.0/24` |

### Interconnection (Transit Gateway + VPC Peering)

All VPCs connect to external networks through a **Transit Gateway** (`main`) and **VPC Peering** connections.

#### Huawei Cloud subnets (routed via TGW)

These are the external subnets reachable from within the VPCs. Used by various partners and services including TIC, Quinto Inversiones, etc.

**Development `us-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19 (agro wks chile), 172.27.20.0/24
```

**Development `sa-east-1`:**
```
172.28.0.0/19
```

**Production `us-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19, 172.27.20.0/22, 172.26.20.0/24,
10.100.100.0/24 (Quinto Inversiones)
```

**Production `sa-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19, 172.27.20.0/22, 172.26.20.0/24,
172.20.0.0/19
```

#### Allaria 359 / Accelerated VPN subnets (routed via TGW)

**Development `us-east-1`:**
```
172.23.6.0/24, 172.20.0.0/21, 10.1.1.18/32, 172.20.27.0/24,
172.20.25.0/24, 172.17.10.0/24, 200.42.14.0/24
```

**Production `us-east-1`:**
```
172.23.6.0/24, 172.20.0.0/21, 200.42.14.0/24 (byma),
172.17.0.0/16, 172.20.27.0/24
```

#### RioPav subnets (routed via TGW)

**Development `us-east-1`:**
```
192.168.121.0/24, 192.168.70.0/24, 192.168.7.0/24,
192.168.21.0/24, 172.29.231.0/24, 172.29.238.0/24, 192.168.244.0/24
```

**Production `us-east-1`:**
```
192.168.121.0/24, 192.168.70.0/24, 192.168.7.0/24,
172.29.231.0/24, 172.29.238.0/24, 192.168.21.0/24
```

#### Other TGW routes

| Destination | Where | What |
|-------------|-------|------|
| `10.0.0.0/16` | Dev us-east-1 | Allariamas (via TGW) |
| `10.1.0.0/16` | Dev us-east-1 | Allariamas shared (via VPC Peering `pcx-0ed193b6e4878a1b4`) |
| `10.6.0.0/16` | Dev us-east-1 | BYMA |
| `10.11.0.0/16` | Dev us-east-1 | Brazil |
| `10.1.131.31/32` | Dev us-east-1 | Bind API (HW VPN) |
| `10.2.0.0/16` | Prod us-east-1 | Allariamas (via TGW) |
| `10.1.0.0/16` | Prod us-east-1 | Allariamas shared (via VPC Peering `pcx-0307a566d49bb2959`) |
| `10.8.0.0/16` | Prod us-east-1 | BYMA |
| `10.1.101.31/32` | Prod us-east-1 | Bind API (HW VPN) |
| `10.10.0.0/16` | Dev sa-east-1 | Virginia dev VPC |
| `172.28.0.0/19` | Dev sa-east-1 | Huawei Chile |

### Lambda networking (important!)

When using the `function` module, Lambda functions are deployed inside the VPC **private subnets**:

```hcl
vpc_config {
  security_group_ids = [aws_security_group.default.id]
  subnet_ids         = var.specific_subnet_ids != null ? var.specific_subnet_ids : local.your_vpcs.private_subnet_ids
}
```

**This means Lambdas do NOT have a fixed IP.** Each invocation gets a dynamic IP from the private subnet pool.

#### What IP to give when someone asks "desde qué IP van a llegar?"

Case A — **La DB/destino está en una red interna conectada por Transit Gateway o VPN** (Huawei, Allaria359, RioPav, BYMA, etc.):

➡ Dar el **CIDR de las private subnets** de la VPC donde está deployada la Lambda:

| Environment | CIDR a dar |
|-------------|------------|
| Dev us-east-1 | `10.10.26.0/24`, `10.10.27.0/24`, `10.10.28.0/24`, `10.10.29.0/24` o directamente `10.10.0.0/16` |
| Dev sa-east-1 | `10.11.26.0/24`, `10.11.27.0/24`, `10.11.28.0/24` o directamente `10.11.0.0/16` |
| Prod us-east-1 | `10.20.26.0/24`, `10.20.27.0/24`, `10.20.28.0/24` o directamente `10.20.0.0/16` |
| Prod sa-east-1 | `10.21.26.0/24`, `10.21.27.0/24`, `10.21.28.0/24` o directamente `10.21.0.0/16` |
| Prod us-east-2 | `10.22.26.0/24`, `10.22.27.0/24`, `10.22.28.0/24` o directamente `10.22.0.0/16` |

Pros: Lo más específico posible son los /24 individuales. Para simplificar, dar el /16 del VPC completo (es rango privado de Allaria igual).

⚠ **Importante:** Si la red de destino no está en las rutas del Transit Gateway (ver listado arriba), hay que agregar una nueva ruta en `main.vpc.tf` de `your-vpcs` apuntando al TGW.

Case B — **La DB/destino está en internet público**:

➡ Dar las **EIPs de los NAT Gateways** de la VPC. Se crean en `infrastructure/modules/vpc/subnets.public.tf` como `aws_eip.eip`. Podés consultarlas en la consola AWS o con:

```bash
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"
```

Case C — **Ideal cuando el destino está en AWS**:

➡ Dar el **Security Group ID** de la Lambda para que lo agreguen en el inbound rule del destino (no aplica si la DB no está en AWS).

#### Verificar conectividad antes de deployar

Si el destino está en una red conectada por TGW, primero validar que exista la ruta en `main.vpc.tf` del `your-vpcs` correspondiente. Las rutas TGW tienen este patrón:

```hcl
resource "aws_route" "to_mi_red_through_transit_gateway" {
  for_each               = toset(module.vpc.private_rt_ids)
  route_table_id         = each.value
  destination_cidr_block = "X.X.X.X/XX"
  transit_gateway_id     = data.aws_ec2_transit_gateway.default.id
}
```

Si no existe, agregarla antes o pedirle a infra que lo haga.

## Before generating HCL

1. Always ask: **what team, what environment (dev/cloud), what VPC?**
2. For any module you're not 100% sure about, **read its README.md** at the path listed above
3. Prefer **PostgreSQL** over MySQL for RDS unless there's a specific reason
4. Check the `team_name` domain mapping: `allaria` vs `allariaagro`
