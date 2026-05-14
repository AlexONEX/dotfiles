---
name: s3-bucket
description: Create S3 buckets with static website hosting, CloudFront, CORS, and SQS notifications
---

## What I do
Create AWS S3 buckets with optional static website hosting, CloudFront CDN, CORS configuration, and SQS event notifications.

## When to use me
Use this module for object storage, static website hosting, or configuring S3 triggers for Lambda functions.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | S3 bucket name | `"my-bucket-${local.environment}"` |

## Common Usage Patterns

### Basic Private Bucket
```hcl
module "data-bucket" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//s3-bucket"
  name   = "my-data-bucket-${local.environment}"
}
```

### Static Website with CloudFront
```hcl
module "frontend" {
  source                 = "git@github.com:allaria-tech/infra-terraform-modules.git//s3-bucket"
  name                   = "app.example.com-${local.environment}"
  create_static_web_page = true
  block_public_access    = false
}
```

### Bucket with CORS
```hcl
module "uploads-bucket" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//s3-bucket"
  name        = "user-uploads-${local.environment}"
  enable_cors = true

  allowed_origins = ["https://app.example.com"]
  allowed_methods = ["GET", "PUT", "POST"]
  allowed_headers = ["*"]
}
```

### Bucket with SQS Notifications
```hcl
module "uploads_bucket" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//s3-bucket"
  name   = "user-uploads-${local.environment}"

  sqs_notifications = [
    {
      queue_arn     = module.uploads_queue.queue_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "incoming/"
    }
  ]
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `create_static_web_page` | Enable static website with CloudFront | `false` |
| `block_public_access` | Block public access | `true` |
| `enable_cors` | Enable CORS | `false` |
| `allowed_origins` | CORS allowed origins | `null` |
| `sqs_notifications` | S3 → SQS notifications | `[]` |

## Outputs
- `name` - S3 bucket name

## Related Modules
- `function` - Lambda functions triggered by S3 events
- `cloudfront` - Standalone CloudFront + S3 setup
- `sqs` - Queues for S3 notifications