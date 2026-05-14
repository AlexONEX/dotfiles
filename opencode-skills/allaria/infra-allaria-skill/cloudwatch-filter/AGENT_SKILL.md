---
name: cloudwatch-filter
description: Create CloudWatch log subscription filters to forward logs to owl-guardian Lambda
---

## What I do
Create CloudWatch Logs subscription filters that forward matching log events to the `owl-guardian` Lambda function for processing.

## When to use me
Use this module to forward specific CloudWatch log events to the owl-guardian system for alerting, monitoring, or processing.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `application_name` | CloudWatch Log Group name | `"/ecs/my-application"` |
| `filter_pattern` | CloudWatch filter pattern | `"ERROR"` |

## Common Usage Patterns

### Basic Error Filtering
```hcl
module "log_filter" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudwatch-filter"
  application_name = "/ecs/my-application"
  filter_pattern   = "ERROR"
}
```

### Match Multiple Patterns
```hcl
module "log_filter" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudwatch-filter"
  application_name = "/ecs/my-application"
  filter_pattern   = "?ERROR ?WARN ?CRITICAL"
}
```

### Match JSON Field
```hcl
module "log_filter" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudwatch-filter"
  application_name = "/ecs/my-application"
  filter_pattern   = "{ $.level = \"error\" }"
}
```

### Forward All Logs
```hcl
module "log_filter" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudwatch-filter"
  application_name = "/ecs/my-application"
  filter_pattern   = ""
}
```

## Variables
| Variable | Description |
|----------|-------------|
| `application_name` | CloudWatch Log Group name |
| `filter_pattern` | Filter pattern string |

## Requirements
- CloudWatch Log Group must already exist
- Lambda function `owl-guardian` must exist in same account/region

## How It Works
1. References existing CloudWatch Log Group
2. Creates subscription filter with specified pattern
3. Grants CloudWatch Logs permission to invoke owl-guardian
4. Matching events are forwarded to Lambda

## Related Modules
- `ecs` - ECS services with CloudWatch logging
- `function` - Lambda functions with logging