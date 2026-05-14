---
name: kinesis
description: Create Kinesis data streams with consumer lag monitoring and CloudWatch alarms
---

## What I do
Create AWS Kinesis Data Streams with configurable capacity mode (ON_DEMAND or PROVISIONED), shard-level metrics, and CloudWatch alarms for consumer lag detection.

## When to use me
Use this module for real-time data streaming, event processing pipelines, or as a data source for Lambda functions.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `stream_name` | Kinesis stream name | `"my-events"` |
| `team_name` | Team owning the stream | `"platform"` |

## Common Usage Patterns

### Basic ON_DEMAND Stream
```hcl
module "events_stream" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//kinesis"
  stream_name = "my-events"
  team_name   = "platform"
}
```

### PROVISIONED Stream with Custom Shards
```hcl
module "events_stream" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//kinesis"
  stream_name = "my-events"
  team_name   = "timba"
  stream_mode = "PROVISIONED"
  shard_count = 4
}
```

### Custom Retention Period
```hcl
module "events_stream" {
  source                = "git@github.com:allaria-tech/infra-terraform-modules.git//kinesis"
  stream_name           = "my-events"
  team_name             = "timba"
  retention_period_hours = 72  # 3 days
}
```

### Custom Iterator Age Threshold
```hcl
module "events_stream" {
  source                 = "git@github.com:allaria-tech/infra-terraform-modules.git//kinesis"
  stream_name            = "my-events"
  team_name              = "pampa"
  iterator_age_threshold_ms = 120000  # 2 minutes behind
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `stream_mode` | Capacity mode | `"ON_DEMAND"` |
| `shard_count` | Shards for PROVISIONED | `1` |
| `retention_period_hours` | Data retention (24-8760) | `24` |
| `iterator_age_threshold_ms` | Alarm threshold (ms) | `60000` |

## Outputs
- `stream_arn` - Kinesis stream ARN
- `widgets` - CloudWatch dashboard widgets

## Alarms
- **High Iterator Age**: Triggers when consumer lag exceeds threshold, indicating slow processing.

## Shard-Level Metrics Enabled
- IncomingBytes, IncomingRecords
- OutgoingBytes, OutgoingRecords
- WriteProvisionedThroughputExceeded
- ReadProvisionedThroughputExceeded
- IteratorAgeMilliseconds

## Related Modules
- `function` - Lambda consumers for Kinesis
- `dms-task` - Can use Kinesis as target