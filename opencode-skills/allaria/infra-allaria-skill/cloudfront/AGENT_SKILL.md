---
name: cloudfront
description: Create CloudFront distributions with S3 origins, SSL certificates, and optional Lambda@Edge
---

## What I do
Create CloudFront distributions with S3 bucket origins for static website hosting, including SSL certificates, DNS configuration, and optional Lambda@Edge for authentication.

## When to use me
Use this module for standalone CloudFront + S3 static websites, or when you need Lambda@Edge authentication (different from s3-bucket's built-in CloudFront).

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | S3 bucket and domain name | `"app.allaria.dev"` |
| `description` | Distribution description | `"Static website for app"` |

## Common Usage Patterns

### Basic Static Website
```hcl
module "static_site" {
  source        = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudfront"
  name          = "app.allaria.dev"
  description   = "Static website for app"
  ttl_in_seconds = 3600
}
```

### With Lambda@Edge Authentication
```hcl
# Lambda@Edge function (must be in us-east-1)
module "cloudfront_auth" {
  source            = "git@github.com:allaria-tech/infra-terraform-modules.git//function"
  function_name     = "cloudfront-auth"
  description       = "Lambda@Edge authentication function"
  timeout_in_seconds = 10
  memory_size_in_mb  = 128
  triggers          = {}

  providers = {
    aws = aws.us-east-1
  }
}

module "protected_site" {
  source        = "git@github.com:allaria-tech/infra-terraform-modules.git//cloudfront"
  name          = "api.allaria.dev"
  description   = "Protected API with Lambda@Edge"
  ttl_in_seconds = 300

  lambda_edge = {
    arn   = module.cloudfront_auth.lambda_arn
    paths = ["/api/*", "/admin/*"]
  }
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `ttl_in_seconds` | Default cache TTL | `0` |
| `lambda_edge` | Lambda@Edge config | `{paths = []}` |

## Resources Created
- S3 bucket for website content
- S3 bucket policy for public read
- CloudFront distribution (https-only)
- ACM SSL certificate
- Route53 DNS records

## Architecture
```
User → Route53 DNS → CloudFront (HTTPS) → S3 Bucket
```

## Lambda@Edge Integration
- Functions must be in us-east-1
- Triggers on `viewer-request` events
- Shorter TTL (5 min) for protected paths
- Forwards `allaria_auth_token` cookie

## Notes
- S3 bucket has `force_destroy = true`
- Default root object: `index.html`
- Error docs redirect to `index.html` (SPA-friendly)
- For dev, use small `ttl_in_seconds` (0 or 60)

## Related Modules
- `s3-bucket` - S3 with built-in CloudFront option
- `function` - Lambda@Edge functions