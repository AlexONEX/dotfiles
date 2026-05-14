---
name: sqs
description: Create SQS queues with dead-letter queues, FIFO support, and CloudWatch alarms
---

## What I do
Create AWS SQS queues with automatic dead-letter queue (DLQ), FIFO support, configurable retention, and CloudWatch alarms.

## When to use me
Use this module when you need message queues for async processing, event-driven architectures, or decoupling services.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `queue_name` | Queue name | `"my-queue"` |

## Common Usage Patterns

### Basic Queue
```hcl
module "orders-queue" {
  source     = "git@github.com:allaria-tech/infra-terraform-modules.git//sqs"
  queue_name = "orders-queue"
}
```

### FIFO Queue
```hcl
module "events-queue" {
  source                      = "git@github.com:allaria-tech/infra-terraform-modules.git//sqs"
  queue_name                  = "events-queue"
  fifo_queue                  = true
  content_based_deduplication = true
}
```

### Queue with Custom Retention
```hcl
module "logs-queue" {
  source                    = "git@github.com:allaria-tech/infra-terraform-modules.git//sqs"
  queue_name                = "logs-queue"
  message_retention_seconds = 604800  # 7 days
  delay_seconds             = 10
}
```

### Long Polling Queue
```hcl
module "tasks-queue" {
  source                    = "git@github.com:allaria-tech/infra-terraform-modules.git//sqs"
  queue_name                = "tasks-queue"
  receive_wait_time_seconds = 20
}
```

### Custom Alarms
```hcl
module "critical-queue" {
  source     = "git@github.com:allaria-tech/infra-terraform-modules.git//sqs"
  queue_name = "critical-queue"

  alarms = {
    message_age_threshold  = 60
    dlq_messages_threshold = 1
    queue_depth_threshold  = 500
  }
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `fifo_queue` | Create FIFO queue | `false` |
| `content_based_deduplication` | Content-based dedup (FIFO) | `false` |
| `message_retention_seconds` | Message retention | `86400` (1 day) |
| `delay_seconds` | Message delay | `0` |
| `receive_wait_time_seconds` | Long polling wait time | `0` |
| `visibility_timeout_seconds` | Visibility timeout | `30` |
| `enable_alarms` | Enable CloudWatch alarms | `true` |

## Outputs
- `sqs_queue_url` - Queue URL
- `sqs_queue_arn` - Queue ARN

## Dead-Letter Queue
Every queue automatically gets a DLQ named `<queue_name>-dlq`. Messages go to DLQ after 3 failed receive attempts.

## Related Modules
- `function` - Lambda consumers for SQS
- `s3-bucket` - S3 triggers that can send to SQS