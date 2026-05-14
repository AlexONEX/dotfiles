---
name: redis-cache
description: Deploy ElastiCache Redis clusters with CloudWatch alarms and automatic DNS
---

## What I do
Create AWS ElastiCache Redis clusters with configurable instance size, CloudWatch alarms for CPU, memory, evictions, and connections, plus automatic Route53 DNS records.

## When to use me
Use this module for caching layers, session storage, or real-time data caching for ECS services or Lambda functions.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Cache cluster name | `"session-cache"` |
| `team_name` | Team owning the cache | `"platform"` |
| `size` | Instance size | `"t4g.micro"` |

## Common Usage Patterns

### Basic Cache
```hcl
module "cache" {
  source    = "git@github.com:allaria-tech/infra-terraform-modules.git//redis-cache"
  name      = "session-cache"
  team_name = "platform"
  size      = "t4g.micro"
}
```

### Larger Instance
```hcl
module "cache" {
  source    = "git@github.com:allaria-tech/infra-terraform-modules.git//redis-cache"
  name      = "high-traffic-cache"
  team_name = "timba"
  size      = "r6g.large"
}
```

### Custom Alarms
```hcl
module "cache" {
  source    = "git@github.com:allaria-tech/infra-terraform-modules.git//redis-cache"
  name      = "critical-cache"
  team_name = "pampa"
  size      = "t4g.small"

  alarms = {
    cpu_utilization_threshold    = 80
    memory_utilization_threshold = 85
    evictions_threshold          = 500
    connections_threshold        = 50000
  }
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `enable_alarms` | Enable CloudWatch alarms | `true` |
| `alarms` | Custom alarm thresholds | (defaults) |

## Alarm Defaults
```hcl
alarms = {
  cpu_utilization_threshold    = 75
  memory_utilization_threshold = 90
  evictions_threshold          = 1000
  connections_threshold        = 65000
}
```

## DNS Records
- Team `timba`, `pampa`, `platform`, `fly`, `cocru`, `oompas`, `dumbo`:
  - Dev: `<name>.cache.internal.allaria.dev`
  - Prod: `<name>.cache.internal.allaria.cloud`
- Team `agro`:
  - Dev: `<name>.cache.internal.allariaagro.dev`
  - Prod: `<name>.cache.internal.allariaagro.cloud`

Port: `6379`

## Common Instance Sizes
| Size | vCPU | Memory |
|------|------|--------|
| `t4g.micro` | 2 | 0.5 GB |
| `t4g.small` | 2 | 1.37 GB |
| `t4g.medium` | 2 | 3.09 GB |
| `r6g.large` | 2 | 13.07 GB |
| `r6g.xlarge` | 4 | 26.32 GB |

## CloudWatch Alarms
- **High CPU**: Triggers when CPU exceeds threshold
- **High Memory**: Triggers when memory exceeds threshold
- **High Evictions**: Triggers when evictions exceed threshold
- **High Connections**: Triggers when connections exceed threshold

Notifications sent to `infra-events-topic`.

## Related Modules
- `ecs` - ECS services using Redis
- `function` - Lambda functions using Redis