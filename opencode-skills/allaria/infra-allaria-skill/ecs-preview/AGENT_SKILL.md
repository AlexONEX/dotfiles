---
name: ecs-preview
description: Deploy ephemeral QA environments per Pull Request with internal preview URLs
---

## What I do
Create short-lived QA environments for pull requests (NOT frontend previews). The preview is accessible at an internal URL and is destroyed when the PR is closed or the `deploy_preview` label is removed.

## When to use me
Use this module to create QA preview environments for PRs in GitHub Actions workflows.

> **Note**: For frontend preview environments, use the `s3p` ECS service in `infra-tf-s3p` instead - it exposes frontends via the public ALB (`*.app.allaria.*`).

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `service_name` | Original ECS service name | `"my-service"` |
| `pr_number` | Pull request number | `42` |

## Common Usage Patterns

### Basic Preview
```hcl
module "preview" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//ecs-preview"

  service_name = "my-service"
  pr_number    = 42
}
```

### With Custom Resources
```hcl
module "preview" {
  source = "git@github.com:allaria-tech/infra-terraform-modules.git//ecs-preview"

  service_name = "my-service"
  pr_number    = 42
  cpu          = 512
  memory       = 1024
  traffic_port = 8080
  domain       = "allaria"
}
```

## Terraform Backend (Per PR)
Configure dynamically in GitHub Actions:
```hcl
terraform {
  backend "s3" {
    bucket = "allaria-development-tf-preview-state"
    key    = "my-service/pr-42/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `cpu` | Fargate CPU units | `256` |
| `memory` | Fargate memory (MiB) | `512` |
| `traffic_port` | Container port | `8080` |
| `health_check` | Health check overrides | `{}` |
| `domain` | Base domain (`allaria` or `allariaagro`) | `"allaria"` |

## Generated Resources
| Resource | Name |
|----------|------|
| ECS service | `{service_name}-pr{pr_number}` |
| Task definition | `{service_name}-pr{pr_number}` |
| CloudWatch log group | `/ecs/preview/{service_name}-pr{pr_number}` |
| Target group | `{service_name}-pr{pr_number}` |
| Route53 record | `{service_name}.pr{pr_number}.svc.internal.{domain}.dev` |

## Outputs
- `service_name` - Preview service name
- `task_definition_arn` - Task definition ARN
- `endpoint` - Internal preview URL
- `log_group_name` - CloudWatch log group (for `build_task_definition.py`)

## How It Works
1. GitHub Actions calls `terraform apply` - creates infrastructure with placeholder image
2. Separate GHA job builds PR image, runs `build_task_definition.py`, updates ECS task
3. Terraform ignores subsequent task definition changes
4. On destroy, all resources are removed

## Requirements
- Reuses existing IAM task role and security group from original service

## Related Modules
- `ecs` - Original ECS service
- `infra-github-actions` - Contains `build_task_definition.py`