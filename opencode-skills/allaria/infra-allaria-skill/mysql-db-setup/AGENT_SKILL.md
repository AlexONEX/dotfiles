---
name: mysql-db-setup
description: Create MySQL databases, users, and store credentials in AWS Secrets Manager
---

## What I do
Automate MySQL database and user creation, granting appropriate privileges and storing credentials in AWS Secrets Manager.

## When to use me
Use this module to set up database access for applications requiring MySQL databases (different from RDS instances).

## Mandatory Parameters
| Variable | Description | Example |
|----------|-------------|---------|
| `application_name` | App name (used as username) | `"myapp"` |
| `db_name` | Database name | `"myapp_db"` |

## Common Usage Patterns

### Basic Application Database
```hcl
module "myapp-db" {
  source           = "git@github.com:allaria-tech/infra-terraform-modules.git//mysql-db-setup"
  application_name = "myapp"
  db_name          = "myapp_db"
}
```

### Lambda Function Database
```hcl
module "processor-db" {
  source           = "git@github.com:allaria-tech/infra-terraform-modules.git//mysql-db-setup"
  application_name = "data-processor"
  db_name          = "processor_db"
  type             = "function"
}
```

### With Additional Privileges
```hcl
module "admin-db" {
  source           = "git@github.com:allaria-tech/infra-terraform-modules.git//mysql-db-setup"
  application_name = "admin-service"
  db_name          = "admin_db"

  other_application_privileges = ["EXECUTE", "CREATE ROUTINE", "ALTER ROUTINE"]
}
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `type` | Application type | `"application"` |
| `other_application_privileges` | Additional MySQL privileges | `[]` |

## Default Privileges Granted
SELECT, UPDATE, ALTER, CREATE, INSERT, DELETE, DROP, REFERENCES, INDEX, CREATE VIEW, LOCK TABLES, TRIGGER

## Secrets Manager
Credentials stored at:
- Applications: `application/<application_name>`
- Functions: `function/<application_name>`

Secret contains: `db_database`, `db_username`, `db_password`

## Requirements
- Existing MySQL server accessible via Terraform MySQL provider
- AWS Secrets Manager secret must exist at target path

## Related Modules
- `rds-instance` - For RDS PostgreSQL/MySQL instances
- `function` - Lambda functions connecting to MySQL
- `ecs` - ECS services connecting to MySQL