---
name: rds-instance
description: Deploy RDS PostgreSQL or MySQL instances with backups, alarms, and security groups
---

## What I do
Deploy RDS database instances (PostgreSQL or MySQL) with automated backups, CloudWatch alarms, and proper security group configuration.

## When to use me
Use this module when you need to create a managed relational database on AWS RDS.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Database name | `"my-app-db"` |
| `engine` | Database engine | `"postgres"` or `"mysql"` |
| `team_name` | Team owning the database | `"platform"`, `"timba"`, etc. |
| `instance_class` | RDS instance class | `"db.t4g.micro"`, `"db.t4g.small"` |
| `allocated_storage_in_gb` | Storage in GB | `20`, `100` |

## Common Usage Patterns

### PostgreSQL (recommended)
```hcl
module "my-db" {
  source                 = "git@github.com:allaria-tech/infra-terraform-modules.git//rds-instance"
  name                   = "my-app-db"
  engine                 = "postgres"
  engine_version         = "17.5"
  team_name              = "platform"
  instance_class         = "db.t4g.micro"
  allocated_storage_in_gb = 20
}
```

### MySQL
```hcl
module "my-db" {
  source                 = "git@github.com:allaria-tech/infra-terraform-modules.git//rds-instance"
  name                   = "my-app-db"
  engine                 = "mysql"
  engine_version         = "8.0.37"
  team_name              = "platform"
  instance_class         = "db.t4g.micro"
  allocated_storage_in_gb = 20
}
```

### Custom Backup Configuration
```hcl
backup = {
  retention_period_in_days = 7
  maintenance_windows      = "06:00-07:00"  # UTC, 3:00-4:00 AM Argentina
}
```

### Custom Alarms
```hcl
alarms = {
  cpu_utilization_threshold      = 90
  database_connections_threshold = 150
  free_storage_space_threshold   = 10737418240  # 10 GB
  freeable_memory_threshold      = 536870912    # 512 MB
}
```

### Allow External CIDR Blocks
```hcl
cidr_blocks_ingress = [
  {
    description = "Office network"
    cidr_blocks = ["10.0.0.0/8"]
  }
]
```

### Custom Database Parameters
```hcl
parameters = {
  "max_connections" = "200"
  "shared_buffers" = "256MB"
}
```

### DMS Source (MySQL binary logging)
```hcl
parameters = {
  "binlog_format"    = "ROW"
  "binlog_row_image" = "Full"
}
```

### S3 VPC Endpoint (for postgres aws_s3 extension)
```hcl
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

prefix_list_egress = [
  {
    description     = "Allow egress to S3"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }
]
```

## Generated Resources
- Daily backups at 9:00 AM Argentina Time (30-day retention)
- Internal DNS: `<name>.db.internal.allaria.dev` / `.allaria.cloud`
- Secrets Manager: `infra/<name>-db-credentials`

## Connection
Access via secrets at `infra/<name>-db-credentials` - creates application users, don't use master credentials.

## Outputs
- `widgets` - CloudWatch dashboard widgets
- `master_credentials_secret_arn` - Secrets Manager ARN
- `db_host` - Database hostname
- `security_group_id` - Security group ID

## Related Modules
- `ecs` - For services that connect to this DB
- `function` - For Lambda functions that connect to this DB
- `aurora-cluster` - For Aurora PostgreSQL clusters