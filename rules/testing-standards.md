# Testing Standards

Follow Go testing best practices for terraform-plugin-framework code.

## Core Testing Principles

1. **Use testify/require** for assertions (not assert)
2. **Never use table-driven tests** (write explicit test functions)
3. **Separate positive and negative tests** (different functions)
4. **Use mockery** for mocking API clients
5. **Test both unit and acceptance levels**

## Required: Use testify/require

### ✅ Correct Pattern

```go
import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestResourceCreate(t *testing.T) {
    // Use require for assertions
    require.NoError(t, err)
    require.Equal(t, expected, actual)
    require.True(t, condition)
    require.NotNil(t, value)
}
```

### ❌ Anti-Pattern

```go
// BAD: Don't use assert (it continues after failure)
assert.Equal(t, expected, actual)

// BAD: Don't use if err != nil checks in tests
if err != nil {
    t.Errorf("error: %v", err)
}
```

## Required: No Table-Driven Tests

### ❌ Anti-Pattern

```go
// BAD: Table-driven test (don't do this)
func TestValidation(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"valid", "test@example.com", false},
        {"invalid", "not-an-email", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Don't do this
        })
    }
}
```

### ✅ Correct Pattern

```go
// GOOD: Explicit test functions
func TestValidation_ValidEmail(t *testing.T) {
    validator := EmailValidator()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("test@example.com"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
}

func TestValidation_InvalidEmail(t *testing.T) {
    validator := EmailValidator()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("not-an-email"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.True(t, resp.Diagnostics.HasError())
}
```

## Required: Separate Positive and Negative Tests

### ✅ Correct Pattern

```go
// GOOD: Separate test functions
func TestResourceCreate(t *testing.T) {
    // Test successful creation
    mockClient := setupMockClient(t)
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(&Pet{
        ID: "pet-123",
    }, nil)

    // ... test successful create ...
}

func TestResourceCreate_APIError(t *testing.T) {
    // Test API error handling
    mockClient := setupMockClient(t)
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(nil, errors.New("API error"))

    // ... test error handling ...
}

func TestResourceCreate_InvalidInput(t *testing.T) {
    // Test validation failure
    // ... test with invalid input ...
}
```

### ❌ Anti-Pattern

```go
// BAD: Mixing positive and negative in one test
func TestResourceCreate(t *testing.T) {
    if validInput {
        // test success
    } else {
        // test error
    }
}
```

## Required: Use Mockery for Mocks

Generate mocks with mockery:

```bash
mockery --name=APIClient --dir=./internal/client --output=./internal/client/mocks
```

### ✅ Correct Pattern

```go
func TestResourceCreate(t *testing.T) {
    mockClient := client.NewMockAPIClient(t)
    mockClient.On("CreatePet", mock.Anything, &client.CreatePetRequest{
        Name:    "Fluffy",
        Species: "cat",
    }).Return(&client.Pet{
        ID:   "pet-123",
        Name: "Fluffy",
    }, nil)

    resource := &PetResource{client: mockClient}

    // ... execute test ...

    mockClient.AssertExpectations(t)
}
```

## Test Organization

### File Naming

```
provider_test.go          # Provider tests
resource_pet_test.go      # Pet resource tests
datasource_pet_test.go    # Pet data source tests
validators_test.go        # Validator tests
function_base64_test.go   # Function tests
```

### Test Function Naming

```go
// Format: Test<Type>_<Scenario>
func TestResourceCreate(t *testing.T)                   // Positive case
func TestResourceCreate_APIError(t *testing.T)          // Negative case
func TestResourceCreate_InvalidInput(t *testing.T)      // Validation failure
func TestResourceUpdate(t *testing.T)                   // Positive case
func TestResourceUpdate_NotFound(t *testing.T)          // Negative case
```

## Acceptance Testing

Use terraform-plugin-testing for acceptance tests:

```go
func TestAccPetResource(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Create and Read
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("example_pet.test", "species", "cat"),
                    resource.TestCheckResourceAttrSet("example_pet.test", "id"),
                ),
            },
            // Import
            {
                ResourceName:      "example_pet.test",
                ImportState:       true,
                ImportStateVerify: true,
            },
            // Update
            {
                Config: testAccPetResourceConfig("Fluffy Updated", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy Updated"),
                ),
            },
        },
    })
}
```

## Test Coverage

Ensure tests cover:
- ✅ All CRUD operations (Create, Read, Update, Delete)
- ✅ Import functionality
- ✅ Validation logic (positive and negative)
- ✅ Error handling (API errors, not found, etc.)
- ✅ Edge cases (null, unknown, empty values)
- ✅ Plan modifiers behavior
- ✅ Cross-attribute validation

## Mock Setup Helpers

```go
func setupMockClient(t *testing.T) *MockAPIClient {
    mockClient := &MockAPIClient{}
    t.Cleanup(func() {
        mockClient.AssertExpectations(t)
    })
    return mockClient
}

func TestResource(t *testing.T) {
    mockClient := setupMockClient(t)
    mockClient.On("Operation", mock.Anything, mock.Anything).Return(result, nil)

    // Test code...
    // AssertExpectations called automatically
}
```

## Running Tests

```bash
# Unit tests
go test ./...

# Acceptance tests
TF_ACC=1 go test ./... -v

# Specific test
go test -run TestAccPetResource ./...

# With coverage
go test -cover ./...
```

## Common Test Patterns

### Test Validator

```go
func TestValidator_Valid(t *testing.T) {
    validator := NewValidator()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("valid-value"),
        Path:        path.Root("field"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
}

func TestValidator_Invalid(t *testing.T) {
    validator := NewValidator()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("invalid-value"),
        Path:        path.Root("field"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.True(t, resp.Diagnostics.HasError())
}
```

### Test Plan Modifier

```go
func TestPlanModifier(t *testing.T) {
    modifier := stringplanmodifier.UseStateForUnknown()

    req := planmodifier.StringRequest{
        StateValue: types.StringValue("existing-value"),
        PlanValue:  types.StringUnknown(),
    }
    resp := &planmodifier.StringResponse{
        PlanValue: req.PlanValue,
    }

    modifier.PlanModifyString(context.Background(), req, resp)

    require.Equal(t, "existing-value", resp.PlanValue.ValueString())
}
```

### Test Function

```go
func TestFunction(t *testing.T) {
    f := NewFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue("input"),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.Nil(t, resp.Error)

    var result string
    resp.Result.Get(context.Background(), &result)
    require.Equal(t, "expected-output", result)
}
```

## Anti-Patterns Summary

### ❌ Don't

- Use assert (use require instead)
- Write table-driven tests
- Mix positive and negative cases in one test
- Skip error checking in tests
- Forget to call mockClient.AssertExpectations(t)

### ✅ Do

- Use require for all assertions
- Write explicit test functions for each scenario
- Separate positive and negative tests
- Use mockery for generating mocks
- Test all CRUD operations
- Include acceptance tests
- Test error handling
- Cover edge cases

## Summary

- ✅ **Always** use testify/require for assertions
- ✅ **Always** write explicit test functions (no table-driven)
- ✅ **Always** separate positive and negative tests
- ✅ **Always** use mockery for mocks
- ✅ **Always** include acceptance tests
- ❌ **Never** use assert (use require)
- ❌ **Never** use table-driven tests
- ❌ **Never** mix positive and negative in one test
