---
name: aurora-cluster
description: Deploy Aurora MySQL clusters with reader/writer endpoints, CloudWatch alarms, and Secrets Manager
---

## What I do
Create Amazon Aurora MySQL clusters with writer/reader endpoints, automatic password generation, security groups, Route53 DNS records, and CloudWatch alarms.

## When to use me
Use this module for production databases requiring high availability with automatic read scaling.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Cluster identifier | `"my-database"` |
| `engine_version` | Aurora engine version | `"8.0.mysql_aurora.3.04.0"` |
| `instance_class` | Instance class | `"db.r6g.large"` |
| `allocated_storage` | Storage in GB | `"100"` |
| `team_name` | Team owning the cluster | `"platform"` |

## Common Usage Patterns

### Basic Aurora Cluster
```hcl
module "aurora_cluster" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//aurora-cluster"

  name              = "my-database"
  engine            = "aurora-mysql"
  engine_version    = "8.0.mysql_aurora.3.04.0"
  instance_class    = "db.r6g.large"
  allocated_storage = "100"
  team_name         = "platform"
}
```

### With Custom Parameters and Alarms
```hcl
module "aurora_cluster" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//aurora-cluster"

  name              = "my-database"
  engine_version    = "8.0.mysql_aurora.3.04.0"
  instance_class    = "db.r6g.large"
  allocated_storage = "100"
  team_name         = "platform"

  parameters = {
    max_connections = "1000"
  }

  alarms = {
    cpu_utilization_threshold      = 80
    database_connections_threshold = 100
    replica_lag_threshold          = 1000
  }
}
```

### From Snapshot
```hcl
module "aurora_cluster" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//aurora-cluster"

  name              = "my-database"
  engine_version    = "8.0.mysql_aurora.3.04.0"
  instance_class    = "db.r6g.large"
  allocated_storage = "100"
  team_name         = "platform"

  snapshot = "existing-snapshot-id"
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `engine` | Aurora engine type | `null` |
| `instance_name` | Custom writer instance name | `null` |
| `snapshot` | Snapshot to restore from | `null` |
| `parameters` | DB parameter group params | `{}` |
| `enable_alarms` | Enable CloudWatch alarms | `true` |

## Outputs
- `writer-endpoint` - Writer endpoint
- `reader-endpoint` - Reader endpoint

## DNS Records
- Writer: `{name}.db.internal.allaria.{dev|cloud}`
- Reader: `{name}-reader.db.internal.allaria.{dev|cloud}`

## Requirements
- VPC state from remote state (`your-vpcs`)
- SNS topic `infra-events-topic` for alarms
- Route53 zone for DNS

## Related Modules
- `rds-instance` - For single-instance RDS
- `ecs` - ECS services connecting to Aurora
- `function` - Lambda functions connecting to Aurora