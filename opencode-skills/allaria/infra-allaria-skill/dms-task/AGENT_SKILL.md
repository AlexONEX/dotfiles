---
name: dms-task
description: Create DMS replication tasks for database migration with CDC, filters, and transformations
---

## What I do
Create AWS Database Migration Service (DMS) replication tasks for full-load, CDC (Change Data Capture), or combined migration with table selection, filtering, and transformation rules.

## When to use me
Use this module to migrate databases to AWS, set up ongoing replication, or filter/transform data during migration.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Replication task name | `"my-replication"` |
| `source_endpoint_arn` | Source DMS endpoint ARN | (ARN) |
| `target_endpoint_arn` | Target DMS endpoint ARN | (ARN) |
| `team_name` | Team owning the task | `"platform"` |
| `rules` | Replication rules | (object) |

## Common Usage Patterns

### Full Load + CDC (Default)
```hcl
module "my_replication" {
  source              = "git@github.com:allaria-tech/infra-terraform-modules.git//dms-task"
  name                = "my-replication"
  source_endpoint_arn = "arn:aws:dms:region:account:endpoint/source-id"
  target_endpoint_arn = "arn:aws:dms:region:account:endpoint/target-id"
  team_name           = "platform"

  rules = {
    source_schema       = "public"
    tables_to_replicate = ["users", "orders", "products"]
  }
}
```

### Serverless Mode
```hcl
module "my_serverless" {
  source              = "git@github.com:allaria-tech/infra-terraform-modules.git//dms-task"
  name                = "my-serverless"
  source_endpoint_arn = (ARN)
  target_endpoint_arn = (ARN)
  team_name           = "platform"

  engine_mode = "serverless"
  max_capacity = 96
  min_capacity = 4

  rules = {
    source_schema       = "public"
    tables_to_replicate = ["users", "orders"]
  }
}
```

### CDC-Only Replication
```hcl
module "cdc_replication" {
  source              = "git@github.com:allaria-tech/infra-terraform-modules.git//dms-task"
  name                = "cdc-only"
  source_endpoint_arn = (ARN)
  target_endpoint_arn = (ARN)
  team_name           = "timba"
  type                = "cdc"

  rules = {
    source_schema       = "public"
    tables_to_replicate = ["orders"]
  }
}
```

### With Filters
```hcl
module "filtered_replication" {
  source              = "git@github.com:allaria-tech/infra-terraform-modules.git//dms-task"
  name                = "filtered"
  source_endpoint_arn = (ARN)
  target_endpoint_arn = (ARN)
  team_name           = "pampa"

  rules = {
    source_schema       = "public"
    tables_to_replicate = ["products"]
    tables_to_replicate_with_filters = [
      {
        table_name = "orders"
        column     = "created_at"
        operator   = "gte"
        value      = "2024-01-01"
      }
    ]
  }
}
```

### With Transformations
```hcl
module "transformed" {
  source              = "git@github.com:allaria-tech/infra-terraform-modules.git//dms-task"
  name                = "transformed"
  source_endpoint_arn = (ARN)
  target_endpoint_arn = (ARN)
  team_name           = "fly"

  rules = {
    source_schema       = "public"
    tables_to_replicate = ["users", "orders"]
    transformation = [
      {
        action      = "add-prefix"
        from        = "users"
        to          = "replica_"
        rule_target = "table"
      }
    ]
  }
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `engine_mode` | `provisioned` or `serverless` | `provisioned` |
| `instance` | Replication instance ID (provisioned) | `default` |
| `max_capacity` | Max capacity (serverless) | `384` |
| `min_capacity` | Min capacity (serverless) | `2` |
| `type` | Migration type | `full-load-and-cdc` |
| `start_replication_task` | Start immediately | `false` |
| `enable_alarms` | Enable CloudWatch alarms | `true` |
| `enable_logging` | Enable CloudWatch logging | `false` |

## Rules Object
```hcl
rules = {
  source_schema                    = string
  tables_to_replicate              = list(string)
  tables_to_replicate_with_filters = list(object)
  transformation                   = list(object)
}
```

## Outputs
- `widgets` - CloudWatch dashboard for CDC latency

## Alarms
Monitors DMS task failure events (DMS-EVENT-0078, DMS-EVENT-0079), sends to `infra-events-topic`.

## Requirements
- Existing DMS source and target endpoints
- For provisioned: existing DMS replication instance
- SNS topic `infra-events-topic`

## Related Modules
- `rds-instance` - Can be DMS target (enable binlog for MySQL)
- `aurora-cluster` - Can be DMS target
- `kinesis` - DMS can target Kinesis