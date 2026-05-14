---
name: keycloak
description: Create Keycloak OIDC clients with role management and service accounts
---

## What I do
Create Keycloak OpenID Connect clients with role definitions, role assignments from other clients, and configurable token lifespan.

## When to use me
Use this module to configure service-to-service authentication via Keycloak, create OIDC clients for applications.

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `name` | Client name (lowercase with hyphens) | `"my-client"` |
| `description` | Client description | `"My service client"` |

## Common Usage Patterns

### Basic Client
```hcl
module "my-client" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//keycloak"
  name        = "my-client"
  description = "My service client"

  allowed_roles = [
    {
      name        = "READ"
      description = "Read access role"
    },
    {
      name        = "ADMIN"
      description = "Administrator role"
    }
  ]
}
```

### With Assigned Roles from Other Clients
```hcl
module "my-client" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//keycloak"
  name        = "my-client"
  description = "A client that needs roles from other services"

  allowed_roles = [
    { name = "TEST", description = "A role for testing" },
    { name = "ADMIN", description = "Super user role" }
  ]

  assigned_roles = {
    "other-client" = {
      roles = ["psp", "admin"]
    }
  }
}
```

### Extended Token Lifespan
```hcl
module "batch-client" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//keycloak"
  name        = "batch-processor"
  description = "Client with extended token lifespan"

  access_token_lifespan_in_days = 7
}
```

### Import Existing Client
```hcl
module "imported-client" {
  source      = "git@github.com:allaria-tech/infra-terraform-modules.git//keycloak"
  name        = "existing-client"
  description = "Import existing client"

  enable_import = true
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `allowed_roles` | List of roles for this client | `[]` |
| `assigned_roles` | Roles to assign from other clients | `{}` |
| `enable_import` | Import existing client | `false` |
| `access_token_lifespan_in_days` | Token lifespan | `1` |
| `convention_disabled` | Disable naming validations | `false` |

## Role Naming Conventions
- Client name: lowercase with hyphens only
- Role names: uppercase with hyphens or colons

## Related Modules
- `function` - Lambda functions that use Keycloak auth
- `ecs` - ECS services that use Keycloak auth