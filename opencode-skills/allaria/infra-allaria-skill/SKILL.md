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

## Before generating HCL

1. Always ask: **what team, what environment (dev/cloud), what VPC?**
2. For any module you're not 100% sure about, **read its README.md** at the path listed above
3. Prefer **PostgreSQL** over MySQL for RDS unless there's a specific reason
4. Check the `team_name` domain mapping: `allaria` vs `allariaagro`
