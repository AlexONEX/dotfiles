---
name: java-quarkus-testing
description: Expert guidance for testing Quarkus applications with comprehensive coverage of unit tests (Mockito), integration tests (@QuarkusTest), E2E tests (RestAssured), and test organization. Covers Given/When/Then naming conventions, test framework selection, mocking strategies, database testing patterns, test data management, and best practices for writing maintainable, type-safe tests. Use when writing new tests, refactoring existing tests, or reviewing test code for Quarkus applications.
argument-hint: <details>
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob", "Edit", "WebSearch", "WebFetch", "Task", "TodoWrite"]
---

# Java Quarkus Testing Expert

Use this skill when writing, reviewing, or refactoring tests for Quarkus-based Java applications. This skill provides comprehensive guidance on testing strategies, framework selection, naming conventions, and best practices specific to Quarkus testing patterns.

Invoke this skill when the user:
- Is writing unit tests for Quarkus services
- Needs to create integration tests for REST APIs
- Asks about testing best practices for Quarkus
- Is writing E2E tests with RestAssured
- Needs help mocking external dependencies
- Requests code reviews for test code
- Wants to improve test coverage or test quality

---

## Test Structure & Framework Selection

### Unit Tests
- **Framework**: Use `@ExtendWith(MockitoExtension.class)` for unit tests with mocks
- **Purpose**: Test individual components in isolation
- **Dependencies**: Mock all external dependencies using Mockito
- **Speed**: Fast execution, no Quarkus context needed
- **Example**:
  ```java
  @ExtendWith(MockitoExtension.class)
  class CustomerServiceTest {
      @Mock
      private CustomerRepository customerRepository;

      @InjectMocks
      private CustomerService target;
  }
  ```

### Integration Tests
- **Framework**: Use `@QuarkusTest` for integration tests that require Quarkus context
- **Purpose**: Test components with real dependencies and framework features
- **Dependencies**: Uses actual beans and database connections
- **Speed**: Slower than unit tests, starts Quarkus application
- **When to Use**: Testing REST endpoints, database interactions, CDI integration
- **Example**:
  ```java
  @QuarkusTest
  class CustomerResourceTest {
      // Tests with real HTTP requests and database
  }
  ```

### External Service Mocks
- Use Mockito to mock external services and dependencies
- Use `@MockBean` in `@QuarkusTest` to replace CDI beans with mocks
- Use WireMock for mocking external HTTP services in integration tests

---

## Test Naming Convention - Given/When/Then

### Pattern
- **Method names**: Use camelCase format
- **Structure**: `given{Context}When{Action}Then{Result}`
- **Given**: Initial context or preconditions (what's the starting state?)
- **When**: Action being performed (what are we doing?)
- **Then**: Expected result (what should happen?)

### Examples
- `givenValidCustomerWhenCreateThenReturnSuccess`
- `givenNonExistentIdWhenFindByIdThenThrowException`
- `givenEmptyDatabaseWhenListAllThenReturnEmptyList`
- `givenExistingCustomerWhenUpdateEmailThenEmailUpdated`
- `givenInvalidEmailWhenCreateThenThrowValidationException`

### Why This Pattern?
- **Readability**: Test intent is immediately clear
- **Consistency**: All tests follow the same structure
- **Documentation**: Test names serve as living documentation
- **Searchability**: Easy to find tests for specific scenarios

---

## Test Organization

### Target Variable
- **Name the class under test as `target`** for quick identification
- Makes it immediately clear what is being tested
- Example:
  ```java
  @InjectMocks
  private CustomerService target;

  @Test
  void givenValidIdWhenFindByIdThenReturnCustomer() {
      Long result = target.findById(1L);
      // ...
  }
  ```

### Setup Methods
- Use `@BeforeEach` for common test setup
- Keep setup focused and minimal
- Create helper methods for complex test data
- Example:
  ```java
  @BeforeEach
  void setUp() {
      // Common setup for all tests
  }

  private CustomerEntity createTestCustomer() {
      return new CustomerEntity(1L, "John", "john@example.com");
  }
  ```

### One Assertion Per Test
- Each test should verify one specific behavior
- Multiple assertions are OK if they verify the same behavior from different angles
- Split complex scenarios into multiple tests

---

## E2E Testing Best Practices

### Use DTOs Directly (NOT JSON Strings)

**✅ CORRECT - Type-safe and refactor-friendly:**
```java
CreateSubscriptionRequest request = new CreateSubscriptionRequest("name", "email@example.com");
given()
    .contentType(ContentType.JSON)
    .body(request)
    .when()
    .post("/api/subscriptions")
    .then()
    .statusCode(201);
```

**❌ AVOID - Brittle and error-prone:**
```java
String json = "{\"name\":\"name\",\"email\":\"email@example.com\"}";
given()
    .contentType(ContentType.JSON)
    .body(json)
    .when()
    .post("/api/subscriptions")
    .then()
    .statusCode(201);
```

**Why DTOs are better:**
- **Type Safety**: Compiler catches errors at build time
- **Refactoring**: IDE refactoring works correctly
- **Maintainability**: Changes to DTOs automatically update tests
- **Readability**: Clear what data is being sent
- **No String Escaping**: Avoid JSON formatting errors

### Database Testing Patterns

#### @Transactional for Database Queries
- Add `@Transactional` to test methods that need to query the database after API calls
- This ensures the test can see data persisted by the endpoint
- Example:
  ```java
  @Test
  @Transactional
  void givenValidRequestWhenCreateCustomerThenDataPersisted() {
      CreateCustomerRequest request = new CreateCustomerRequest("Jane", "jane@example.com");

      given()
          .contentType(ContentType.JSON)
          .body(request)
          .when()
          .post("/api/customers")
          .then()
          .statusCode(201);

      // Verify database state
      CustomerEntity created = CustomerEntity.find("email", "jane@example.com").firstResult();
      assertNotNull(created);
      assertEquals("Jane", created.getName());
  }
  ```

#### Test Data Cleanup
- Use `@TestTransaction` for automatic rollback after each test
- Use manual cleanup in `@AfterEach` if needed
- Ensure test isolation - tests should not depend on each other
- Example:
  ```java
  @AfterEach
  @Transactional
  void cleanup() {
      CustomerEntity.deleteAll();
  }
  ```

---

## Complete Test Examples

### Unit Test Example
```java
@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {
    @Mock
    private CustomerRepository customerRepository;

    @InjectMocks
    private CustomerService target;

    @Test
    void givenValidCustomerWhenCreateThenReturnCustomerId() {
        // Given
        CreateCustomerRequest request = new CreateCustomerRequest("John", "john@example.com");
        CustomerEntity entity = new CustomerEntity(null, "John", "john@example.com");
        when(customerRepository.persist(any(CustomerEntity.class))).thenReturn(entity);

        // When
        Long customerId = target.createCustomer(request);

        // Then
        assertNotNull(customerId);
        verify(customerRepository).persist(any(CustomerEntity.class));
    }

    @Test
    void givenNonExistentIdWhenFindByIdThenThrowException() {
        // Given
        Long customerId = 999L;
        when(customerRepository.findById(customerId)).thenReturn(null);

        // When & Then
        assertThrows(NotFoundException.class, () -> target.findById(customerId));
    }
}
```

### Integration Test Example
```java
@QuarkusTest
class CustomerResourceTest {
    @Test
    @Transactional
    void givenValidRequestWhenCreateCustomerThenReturnCreated() {
        // Given
        CreateCustomerRequest request = new CreateCustomerRequest("Jane", "jane@example.com");

        // When & Then
        given()
            .contentType(ContentType.JSON)
            .body(request)
            .when()
            .post("/api/customers")
            .then()
            .statusCode(201)
            .body("message", equalTo("Customer created successfully"));

        // Verify database state
        CustomerEntity created = CustomerEntity.find("email", "jane@example.com").firstResult();
        assertNotNull(created);
        assertEquals("Jane", created.getName());
    }

    @Test
    void givenNonExistentIdWhenGetCustomerThenReturn404() {
        // When & Then
        given()
            .when()
            .get("/api/customers/99999")
            .then()
            .statusCode(404);
    }
}
```

---

## Test Code Quality Checklist

When reviewing or writing test code, ensure:
- [ ] Tests follow Given/When/Then naming convention
- [ ] Class under test is named `target`
- [ ] Unit tests use `@ExtendWith(MockitoExtension.class)`
- [ ] Integration tests use `@QuarkusTest`
- [ ] E2E tests use DTO instances (not JSON strings)
- [ ] Database verification tests have `@Transactional`
- [ ] Test data cleanup is implemented
- [ ] One behavior per test method
- [ ] Tests are independent and can run in any order
- [ ] All mocks are properly configured with `when(...).thenReturn(...)`
- [ ] Assertions verify expected behavior clearly
- [ ] No hardcoded sensitive data (use test fixtures)

---

## Common Testing Patterns

### Testing Exceptions
```java
@Test
void givenInvalidEmailWhenCreateThenThrowValidationException() {
    // Given
    CreateCustomerRequest request = new CreateCustomerRequest("John", "invalid-email");

    // When & Then
    assertThrows(ValidationException.class, () -> target.createCustomer(request));
}
```

### Testing Collections
```java
@Test
void givenMultipleCustomersWhenListAllThenReturnAll() {
    // Given
    List<CustomerEntity> customers = List.of(
        new CustomerEntity(1L, "John", "john@example.com"),
        new CustomerEntity(2L, "Jane", "jane@example.com")
    );
    when(customerRepository.listAll()).thenReturn(customers);

    // When
    List<Customer> result = target.listAll();

    // Then
    assertEquals(2, result.size());
    assertEquals("John", result.get(0).name());
}
```

### Testing Async Operations
```java
@Test
void givenAsyncOperationWhenCompleteThenReturnResult() throws Exception {
    // Given
    CompletableFuture<String> future = CompletableFuture.completedFuture("result");
    when(asyncService.doSomething()).thenReturn(future);

    // When
    String result = target.performAsyncOperation().get(5, TimeUnit.SECONDS);

    // Then
    assertEquals("result", result);
}
```

---

**Remember**: Good tests are readable, maintainable, and provide confidence in your code. They should serve as documentation and catch regressions early. When in doubt, favor clarity and explicitness over cleverness.
