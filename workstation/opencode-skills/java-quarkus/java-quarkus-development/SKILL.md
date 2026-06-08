---
name: java-quarkus-development
description: "Comprehensive development guide for ALL Java/Quarkus development work, from simple changes to complex integrations. Covers: external API integration (@RegisterRestClient, Keycloak, OAuth), dependency injection, transaction management, REST APIs with records/DTOs, Panache persistence, JPA entities with Lombok, Flyway migrations, file organization (gateway structure), configuration, scheduled jobs, and error handling. Use for both creating new code and modifying existing code to ensure consistency with project conventions and avoid common Quarkus pitfalls."
argument-hint: <details>
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob", "Edit", "WebSearch", "WebFetch", "Task", "TodoWrite"]
---

# Java Quarkus Development Expert

Use this skill when working on Quarkus-based Java applications. This skill provides comprehensive guidance on Quarkus best practices, including dependency injection, transaction management, REST API design, persistence patterns, and file organization standards.

Invoke this skill when the user:
- Is developing or refactoring Quarkus applications
- Needs guidance on Quarkus architecture patterns
- Asks about Java/Quarkus best practices
- Is implementing REST APIs, services, or persistence layers in Quarkus
- Requests code reviews for Java/Quarkus code

---

## Core Principles

### Dependency Injection
- **MANDATORY**: Always use constructor injection, never field injection with @Inject
- Declare dependencies as `private final` fields
- Create a public constructor that receives all dependencies
- **Example**:
  ```java
  @ApplicationScoped
  public class MyService {
      private final MyRepository repository;
      private final OtherService otherService;

      public MyService(MyRepository repository, OtherService otherService) {
          this.repository = repository;
          this.otherService = otherService;
      }
  }
  ```
- **NEVER use**: `@Inject` on fields

### Transaction Management
- **@Transactional at entry points**: Use `@Transactional` at REST controllers and scheduled jobs, NOT in service layer
- **Scheduled Jobs**: Add `@Transactional` to `@Scheduled` methods
- **Rationale**: Transaction boundaries should be defined at the entry points of your application (controllers, jobs), not scattered throughout the service layer
- **Example**:
  ```java
  // ✅ Controller - Define transaction boundary here
  @POST
  @Transactional
  public MessageResponse createSubscription(CreateSubscriptionRequest request) {
      return service.createSubscription(...);
  }

  // ✅ Scheduled Job - Define transaction boundary here
  @Scheduled(every = "60s")
  @Transactional
  public void processJobs() {
      service.processJobs();
  }

  // ✅ Service - NO @Transactional (inherits from caller)
  public Long createSubscription(...) {
      // Business logic here
      // Transaction is managed by the controller
  }
  ```

## File Organization & Architecture

### REST Controllers (`api/rest/`)
- **DTOs as Records**: Use Java records for all request/response DTOs
- **Direct Returns**: Return DTOs directly, not wrapped in `Response.ok().build()`
  - ✅ Correct: `return responseDto;`
  - ❌ Avoid: `return Response.ok(responseDto).build();`
- **Generic Success Response**: Use a generic `SuccessResponse` DTO for simple success responses
- **Keep Controllers Thin**: Controllers should only handle HTTP concerns (validation, mapping), delegate business logic to services

### Business Logic (`domain/service/`)
- Place all business logic in service classes
- Services should be stateless and focused on a single domain
- Use constructor injection for dependencies
- Do NOT add `@Transactional` annotations (inherit from controllers/jobs)

### Domain Models (`domain/model/`)
- **MANDATORY**: Domain models must always be Java records
- Records provide immutability, automatic getters, equals/hashCode, and toString
- **Example**:
  ```java
  public record Customer(
      Long id,
      String name,
      String email,
      LocalDateTime createdAt
  ) {}
  ```

### Persistence Layer (`persistence/`)
- **Panache Pattern**: Use Panache query methods for database operations
- **Null Handling**: Always handle null returns from database queries appropriately
- **Entities**: Place JPA entities in `persistence/entity/`
- **Repositories**: Place Panache repositories in `persistence/`

#### Lookup by Unique Fields — Naming Convention
- **MANDATORY**: When a repository method searches by a unique field, it must be named `findByXxxOrThrow()` — never return `Optional<T>` for these lookups
- The method throws an exception if the entity is not found (use `Require.that()` or throw directly)
- **Examples**:
  ```java
  // ✅ Correct
  public MyEntity findByIdOrThrow(Long id) {
      MyEntity entity = findById(id);
      Require.that(entity != null, "Entity not found with id: " + id);
      return entity;
  }

  public MyEntity findByNameOrThrow(String name) {
      MyEntity entity = find("name", name).firstResult();
      Require.that(entity != null, "Entity not found with name: " + name);
      return entity;
  }

  // ❌ Avoid for unique-field lookups
  Optional<MyEntity> findActiveById(Long id);
  ```
- **Rule**: Only use `Optional<T>` when the absence of a result is a valid, expected outcome that the caller needs to handle. For unique-field lookups where not finding the entity is an error, always use `OrThrow` naming.

#### JPA Entities - Lombok Annotations
- **@Getter**: Use for automatic getter methods
- **@NoArgsConstructor**: Required by JPA for entity instantiation
- **@AllArgsConstructor**: Use only for required fields (non-nullable, non-generated)
- **Example**:
  ```java
  @Entity
  @Table(name = "customers")
  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  public class CustomerEntity extends PanacheEntityBase {
      @Id
      @GeneratedValue(strategy = GenerationType.IDENTITY)
      private Long id;

      @Column(nullable = false)
      private String name;

      @Column(nullable = false, unique = true)
      private String email;

      // Timestamp fields below...
  }
  ```

#### Timestamp Fields - MANDATORY
- **CRITICAL**: All JPA entities must have both `created_at` and `updated_at` fields
- Use `@Column(name = "created_at", nullable = false, updatable = false)` for creation timestamp
- Use `@Column(name = "updated_at")` for update timestamp
- Implement `@PrePersist` method to set both timestamps on creation
- Implement `@PreUpdate` method to update `updatedAt` on modifications
- **Example**:
  ```java
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @PrePersist
  protected void onCreate() {
      createdAt = LocalDateTime.now();
      updatedAt = LocalDateTime.now();
  }

  @PreUpdate
  protected void onUpdate() {
      updatedAt = LocalDateTime.now();
  }
  ```

#### Flyway Migrations
- **NEVER modify existing migration files** unless you're in active development and the migration hasn't been deployed
- **SQL Syntax**: Use MySQL-compatible syntax for all migration files
- **Naming**: Follow pattern `V{version}__{description}.sql` (e.g., `V1__create_customers_table.sql`)
- **Always include timestamp fields** in CREATE TABLE statements

### External API Clients (`gateway/{apiname}/`)
- **Structure**:
  - HTTP client with `@RegisterRestClient` goes directly in the API folder root
  - `req/` subdirectory: Request DTOs (records for sending data)
  - `res/` subdirectory: Response DTOs (records for receiving data)
- **Example Structure**:
  ```
  gateway/
    └── stripe/
        ├── StripeClient.java          # @RegisterRestClient interface
        ├── req/
        │   └── CreatePaymentRequest.java
        └── res/
            └── PaymentResponse.java
  ```

#### Configuration - Environment Variables
- **MANDATORY**: When configuring a new integration (consuming a new API), the host URL in `application.properties` must ALWAYS point to an environment variable
- **Pattern**: `quarkus.rest-client.{api-name}.url=${ENV_VAR_NAME}`
- **Example**:
  ```properties
  # ✅ Correct - Using environment variable
  quarkus.rest-client.keycloak-api.url=${KEYCLOAK_URL}
  quarkus.rest-client.stripe-api.url=${STRIPE_API_URL}

  # ❌ Avoid - Hardcoded URL
  quarkus.rest-client.keycloak-api.url=https://auth.example.com
  ```
- **Rationale**: Using environment variables allows for different configurations across environments (dev, staging, production) without code changes

## Code Quality Checklist

When reviewing or writing Quarkus code, ensure:
- [ ] **Build passes** (`./gradlew build -x test`)
- [ ] Constructor injection used (no `@Inject` on fields)
- [ ] REST clients injected with `@RestClient` qualifier
- [ ] `@Transactional` only at entry points (controllers, jobs)
- [ ] DTOs are Java records
- [ ] Controllers return DTOs directly (no `Response.ok()` wrapping)
- [ ] JPA entities have `@Getter`, `@NoArgsConstructor`, and appropriate `@AllArgsConstructor`
- [ ] All entities have `created_at` and `updated_at` with `@PrePersist` and `@PreUpdate`
- [ ] Domain models are records
- [ ] Flyway migrations never modified after deployment
- [ ] External API clients follow `gateway/{apiname}/` structure with `req/` and `res/` subdirectories
- [ ] Business validations use `Require.that()` utility class (no manual if-throw)
- [ ] Unique-field repository lookups use `findByXxxOrThrow()` naming (no `Optional<T>` for these)
- [ ] REST client URLs in `application.properties` use environment variables (no hardcoded URLs)
- [ ] Code does not contain emojis or icons (use plain text only)

## Additional Best Practices

### REST API Design
- Use standard HTTP status codes appropriately
- Use path parameters for resource IDs (`/customers/{id}`)
- Use query parameters for filtering/pagination
- Version APIs when making breaking changes (`/api/v1/customers`)

### Error Handling
- Create custom exception classes that extend `RuntimeException`
- Use `@Provider` with `ExceptionMapper` for global exception handling
- Return consistent error response format across all endpoints

### Validation
- **MANDATORY**: Use the `Require` utility class (located in `util/` package) for all business validations
- **Pattern**: `Require.that(condition, errorMessage)`
- The `Require` class provides a clean, consistent way to validate business rules and throw appropriate exceptions
- **Example**:
  ```java
  // ✅ Correct - Using Require utility
  Require.that(!subscriptionRepository.existsByCuitAndPlanId(cuit, planId),
      String.format("CUIT %d is already subscribed to plan '%s'", cuit, plan.getName()));

  // ✅ Another example
  Require.that(customer != null, "Customer not found");

  // ✅ Validating non-null
  Require.that(email != null && !email.isEmpty(), "Email is required");
  ```
- **NEVER use**: Manual `if` statements with `throw` for business validations
  ```java
  // ❌ Avoid - Manual if-throw
  if (subscriptionRepository.existsByCuitAndPlanId(cuit, planId)) {
      throw new BusinessException(String.format("CUIT %d is already subscribed to plan '%s'", cuit, plan.getName()));
  }
  ```

### Logging
- Use SLF4J with appropriate log levels
- Log at INFO for significant business events
- Log at DEBUG for detailed troubleshooting
- Log at ERROR for exceptions (include stack traces)
- Never log sensitive data (passwords, tokens, PII)

### Code Style
- **MANDATORY**: Never use emojis or icons in code (comments, strings, logs, etc.)
- Keep all code plain text and ASCII-compatible

---

**Remember**: These patterns promote maintainability, testability, and consistency across Quarkus applications. When in doubt, favor explicitness and clarity over cleverness.
