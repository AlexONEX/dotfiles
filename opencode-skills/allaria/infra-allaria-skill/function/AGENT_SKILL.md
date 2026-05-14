---
name: function
description: Deploy AWS Lambda functions with triggers (ALB, SQS, S3, Kinesis, EventBridge)
---

## What I do
Deploy serverless AWS Lambda functions with various event triggers including ALB, SQS, S3, Kinesis, and EventBridge.

## When to use me
Use this module when you need to deploy a serverless function that responds to events, schedules, or HTTP requests.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `function_name` | Lambda function name | `"my-function"` |
| `description` | Function description | `"Processes queue messages"` |
| `timeout_in_seconds` | Max execution time (1-900) | `30`, `300`, `900` |
| `memory_size_in_mb` | RAM (128-10240) | `128`, `512`, `1024` |
| `triggers` | Map of trigger configs | See patterns below |

## Common Usage Patterns

### Basic Lambda (no triggers)
```hcl
module "my-function" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//function"
  function_name     = "my-function"
  description       = "My Lambda function"
  timeout_in_seconds = 30
  memory_size_in_mb  = 256
  triggers          = {}
}
```

### Scheduled (EventBridge Cron)
```hcl
triggers = {
  "event_bridge" = {
    schedule_expression = "cron(0 9 ? * * *)"
  }
}
```

### Internal API (Private ALB)
```hcl
triggers = {
  "alb" = {}
}
# Access at: my-function.svc.internal.allaria.dev/
```

### Public API (Internet ALB)
```hcl
triggers = {
  "external_alb" = {
    path_pattern = "/my-function/*"
  }
}
# Access at: api.allaria.dev/my-function/*
```

### B2B API (IP-filtered)
```hcl
triggers = {
  "b2b_alb" = {
    path_pattern = "/b2b-api/*"
  }
}
```

### SQS Trigger
```hcl
triggers = {
  "sqs" = {
    queue_arn  = module.my_queue.sqs_queue_arn
    batch_size = 1
  }
}
```

### S3 Trigger
```hcl
triggers = {
  "s3" = {
    bucket_name    = "my-bucket"
    filter_prefix  = "incoming/"
    filter_suffix  = ".json"
  }
}
```

### Kinesis Trigger
```hcl
triggers = {
  "kinesis" = {
    name = "my-stream-name"
  }
}
```

### Multiple Triggers
```hcl
triggers = {
  external_alb = { path_pattern = "/api/*" }
  sqs          = { queue_name = "my-queue" }
  events       = { schedule_expression = "rate(1 hour)" }
}
```

## Custom IAM Permissions
```hcl
allowed_actions = [
  "s3:GetObject",
  "logs:GetLogEvents"
]
```

## Custom Alarms
```hcl
alarms = {
  enabled              = true
  error_rate_threshold = 10  # Default: 25%
}
```

## Generated DNS
- Internal: `<function_name>.svc.internal.allaria.dev` / `.allaria.cloud`

## Outputs
- `widgets` - CloudWatch dashboard widgets

## Related Modules
- `ecs` - For containerized services
- `sqs` - For message queues
- `s3-bucket` - For object storage triggers
- `kinesis` - For stream processing