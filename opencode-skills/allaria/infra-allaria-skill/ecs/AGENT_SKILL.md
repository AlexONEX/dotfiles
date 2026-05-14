---
name: ecs
description: Deploy ECS Fargate services with ALB integration, auto-scaling, and CloudWatch monitoring
---

## What I do
Deploy and manage AWS ECS Fargate services with automatic load balancing, scaling policies, health checks, and monitoring.

## When to use me
Use this module when you need to deploy a containerized API or service on AWS ECS Fargate.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Service name | `"my-service"` |
| `description` | Service description | `"My API service"` |
| `team_name` | Team owning the service | `"platform"`, `"timba"`, `"fly"`, etc. |
| `health_check.path` | Health check endpoint path | `"/health"` |

## Common Usage Patterns

### Basic Service
```hcl
module "my-service" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//ecs"
  name        = "my-service"
  description = "My API service"
  team_name   = "platform"
  health_check = { path = "/health" }
}
```

### Expose to Internet (by subdomain)
```hcl
alb_config = {
  public = {
    expose       = true
    host_header = "my-service.*"
  }
}
```

### Expose to Internet (by path)
```hcl
alb_config = {
  public = {
    expose = true
    path   = ["/my-service/*"]
  }
}
```

### Expose with IP Filtering (B2B)
```hcl
alb_config = {
  b2b = {
    expose      = true
    host_header = "my-service.*"
    source_ips  = ["123.123.123.123/32"]
  }
}
```

### Auto-scaling (CPU-based)
```hcl
cpu_scaling = {
  up   = 75  # Scale up at 75% CPU
  down = 30  # Scale down at 30% CPU
}
```

### Scheduled Scaling
```hcl
scheduled_scaling = {
  enabled = true
  scale_up = {
    cron         = "0 8 ? * MON-FRI *"
    min_capacity = 5
  }
  scale_down = {
    cron         = "0 20 * * ? *"
    min_capacity = 1
  }
}
```

### Add S3 Permissions
```hcl
allowed_actions = [
  "s3:GetObject",
  "s3:PutObject",
  "s3:ListBucket"
]
```

### Enable OpenTelemetry (ADOT)
```hcl
adot_enable = true
```

### Enable Contextor (error logging to Discord)
```hcl
contextor_filter_pattern = "[ERROR]"
```

## Generated DNS
- Internal: `<name>.svc.internal.allaria.dev` / `.allaria.cloud`
- Public: `<name>.api.allaria.dev` or `api.allaria.dev/<path>/*`

## Outputs
- `secret_id` - Secrets Manager secret ID
- `widgets` - CloudWatch dashboard widgets

## Related Modules
- `function` - For Lambda functions
- `rds-instance` - For databases
- `s3-bucket` - For object storage