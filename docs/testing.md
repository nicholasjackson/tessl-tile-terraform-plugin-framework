# Testing

Test Terraform providers with acceptance tests (terraform-plugin-testing) for resources and data sources, and unit tests (testify/require) for helper functions.

## Overview

Provider testing follows the standard Terraform provider convention:

- **Acceptance Tests**: Full lifecycle tests using `resource.Test` from terraform-plugin-testing. This is the primary test type for all resources and data sources.
- **Unit Tests**: Direct function tests for validators, plan modifiers, provider functions, and utility helpers.

**Key principle:** Resources and data sources are tested with acceptance tests, not unit tests with mocks. This is the established convention across all major Terraform providers.

## Acceptance Testing

Acceptance tests use `terraform-plugin-testing` to run real Terraform operations (plan, apply, destroy) against your provider. Every resource and data source must have acceptance tests.

### Provider Factory Setup

```go
import (
    "os"
    "testing"

    "github.com/hashicorp/terraform-plugin-framework/providerserver"
    "github.com/hashicorp/terraform-plugin-go/tfprotov6"
)

var testAccProtoV6ProviderFactories = map[string]func() (tfprotov6.ProviderServer, error){
    "example": providerserver.NewProtocol6WithError(New("test")()),
}

func testAccPreCheck(t *testing.T) {
    // Verify required environment variables are set
    if v := os.Getenv("EXAMPLE_API_ENDPOINT"); v == "" {
        t.Fatal("EXAMPLE_API_ENDPOINT must be set for acceptance tests")
    }
}
```

### Resource Acceptance Tests

Each resource should have tests covering: basic create/read, update, import state, and optionally disappears (external deletion).

#### Create and Read

```go
func TestAccPetResource_basic(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        CheckDestroy:             testAccCheckPetDestroy,
        Steps: []resource.TestStep{
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("example_pet.test", "species", "cat"),
                    resource.TestCheckResourceAttrSet("example_pet.test", "id"),
                    resource.TestCheckResourceAttrSet("example_pet.test", "created_at"),
                ),
            },
        },
    })
}
```

#### Update

```go
func TestAccPetResource_update(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        CheckDestroy:             testAccCheckPetDestroy,
        Steps: []resource.TestStep{
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
                ),
            },
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

#### Import State

```go
func TestAccPetResource_import(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        CheckDestroy:             testAccCheckPetDestroy,
        Steps: []resource.TestStep{
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
            },
            {
                ResourceName:      "example_pet.test",
                ImportState:       true,
                ImportStateVerify: true,
                // Ignore fields that can't be imported
                ImportStateVerifyIgnore: []string{"last_updated"},
            },
        },
    })
}
```

#### ExpectError

```go
func TestAccPetResource_invalidSpecies(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config:      testAccPetResourceConfig("Fluffy", "invalid"),
                ExpectError: regexp.MustCompile(`Invalid species`),
            },
        },
    })
}
```

### Data Source Acceptance Tests

Data source tests typically create a resource first, then read it via the data source and verify the attributes match.

```go
func TestAccPetDataSource_basic(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config: testAccPetDataSourceConfig("Fluffy"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("data.example_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("data.example_pet.test", "species", "cat"),
                ),
            },
        },
    })
}

func testAccPetDataSourceConfig(name string) string {
    return fmt.Sprintf(`
data "example_pet" "test" {
  name = %[1]q
}
`, name)
}
```

When a data source depends on a resource existing first:

```go
func testAccPetDataSourceConfig_withResource(name, species string) string {
    return fmt.Sprintf(`
resource "example_pet" "setup" {
  name    = %[1]q
  species = %[2]q
}

data "example_pet" "test" {
  id = example_pet.setup.id
}
`, name, species)
}
```

### HCL Config Helpers

Config helper functions generate Terraform HCL configurations for tests:

```go
func testAccPetResourceConfig(name, species string) string {
    return fmt.Sprintf(`
resource "example_pet" "test" {
  name    = %[1]q
  species = %[2]q
}
`, name, species)
}
```

For complex configurations with provider settings:

```go
func testAccProviderConfig() string {
    return `
provider "example" {
  endpoint = "https://api.example.com"
}
`
}

func testAccPetResourceConfig_full(name, species string, age int) string {
    return testAccProviderConfig() + fmt.Sprintf(`
resource "example_pet" "test" {
  name    = %[1]q
  species = %[2]q
  age     = %[3]d
}
`, name, species, age)
}
```

### CheckDestroy Functions

Verify resources are cleaned up after test completion:

```go
func testAccCheckPetDestroy(s *terraform.State) error {
    for _, rs := range s.RootModule().Resources {
        if rs.Type != "example_pet" {
            continue
        }

        _, err := apiClient.GetPet(context.Background(), rs.Primary.ID)
        if err == nil {
            return fmt.Errorf("pet %s still exists", rs.Primary.ID)
        }
    }
    return nil
}
```

### Custom Check Functions

```go
func testAccCheckPetExists(resourceName string) resource.TestCheckFunc {
    return func(s *terraform.State) error {
        rs, ok := s.RootModule().Resources[resourceName]
        if !ok {
            return fmt.Errorf("not found: %s", resourceName)
        }

        if rs.Primary.ID == "" {
            return fmt.Errorf("pet ID is not set")
        }

        _, err := apiClient.GetPet(context.Background(), rs.Primary.ID)
        return err
    }
}
```

### Acceptance Test Naming Convention

```go
// Format: TestAcc<Resource>_<scenario>
func TestAccPetResource_basic(t *testing.T)
func TestAccPetResource_update(t *testing.T)
func TestAccPetResource_import(t *testing.T)
func TestAccPetResource_disappears(t *testing.T)
func TestAccPetResource_invalidSpecies(t *testing.T)

func TestAccPetDataSource_basic(t *testing.T)
func TestAccPetDataSource_byName(t *testing.T)
```

## Unit Testing

Unit tests are appropriate for helper functions that don't need the full Terraform lifecycle. Use testify/require for assertions.

### Testing Validators

```go
func TestEmailValidator_Valid(t *testing.T) {
    validator := validators.Email()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("user@example.com"),
        Path:        path.Root("email"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
}

func TestEmailValidator_Invalid(t *testing.T) {
    validator := validators.Email()

    req := validator.StringRequest{
        ConfigValue: types.StringValue("invalid-email"),
        Path:        path.Root("email"),
    }
    resp := &validator.StringResponse{}

    validator.ValidateString(context.Background(), req, resp)

    require.True(t, resp.Diagnostics.HasError())
    require.Contains(t, resp.Diagnostics.Errors()[0].Summary(), "Invalid Email")
}
```

### Testing Plan Modifiers

```go
func TestUseStateForUnknownModifier(t *testing.T) {
    modifier := stringplanmodifier.UseStateForUnknown()

    req := planmodifier.StringRequest{
        StateValue: types.StringValue("existing-id"),
        PlanValue:  types.StringUnknown(),
    }
    resp := &planmodifier.StringResponse{
        PlanValue: req.PlanValue,
    }

    modifier.PlanModifyString(context.Background(), req, resp)

    require.Equal(t, "existing-id", resp.PlanValue.ValueString())
}

func TestRequiresReplaceModifier(t *testing.T) {
    modifier := stringplanmodifier.RequiresReplace()

    req := planmodifier.StringRequest{
        StateValue: types.StringValue("old-value"),
        PlanValue:  types.StringValue("new-value"),
    }
    resp := &planmodifier.StringResponse{
        PlanValue: req.PlanValue,
    }

    modifier.PlanModifyString(context.Background(), req, resp)

    require.True(t, resp.RequiresReplace)
}
```

### Testing Provider Functions

```go
func TestBase64EncodeFunction(t *testing.T) {
    f := NewBase64EncodeFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue("hello"),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.Nil(t, resp.Error)

    var result string
    resp.Result.Get(context.Background(), &result)
    require.Equal(t, "aGVsbG8=", result)
}

func TestBase64EncodeFunction_EmptyInput(t *testing.T) {
    f := NewBase64EncodeFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue(""),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.Nil(t, resp.Error)

    var result string
    resp.Result.Get(context.Background(), &result)
    require.Equal(t, "", result)
}
```

### Function Acceptance Tests

Provider functions can also be tested via acceptance tests:

```go
func TestAccBase64EncodeFunction(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config: `
output "encoded" {
  value = provider::example::base64_encode("hello")
}
`,
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckOutput("encoded", "aGVsbG8="),
                ),
            },
        },
    })
}
```

## Test Organization

```
provider_test.go          # Provider factory setup, precheck, shared helpers
resource_pet_test.go      # Pet resource acceptance tests
datasource_pet_test.go    # Pet data source acceptance tests
validators_test.go        # Validator unit tests
planmodifiers_test.go     # Plan modifier unit tests
function_base64_test.go   # Function unit tests
```

## Running Tests

```bash
# Unit tests only (no TF_ACC)
go test ./... -count=1

# Acceptance tests
TF_ACC=1 go test ./... -v

# Specific acceptance test
TF_ACC=1 go test -run TestAccPetResource ./... -v

# With coverage
go test -cover ./...
```

## Testing Best Practices

### Separate Positive and Negative Tests

```go
// GOOD: Separate test functions
func TestAccPetResource_basic(t *testing.T) {
    // Test successful creation
}

func TestAccPetResource_invalidSpecies(t *testing.T) {
    // Test validation error
}
```

### Use require for Unit Test Assertions

```go
// GOOD: Use require (stops on failure)
require.Equal(t, expected, actual)
require.NoError(t, err)
require.True(t, condition)

// BAD: Use assert (continues on failure, may cause confusing cascading errors)
assert.Equal(t, expected, actual)
```

### Test Coverage

Acceptance tests should cover:
- All CRUD operations (Create, Read, Update, Delete)
- Import state functionality
- Validation logic (ExpectError)
- Attribute-specific updates

Unit tests should cover:
- Custom validators (valid and invalid inputs)
- Custom plan modifiers
- Provider functions
- Utility/helper functions

## External References

- [Testing Guide](https://developer.hashicorp.com/terraform/plugin/framework/testing)
- [terraform-plugin-testing](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-testing)
- [Acceptance Tests](https://developer.hashicorp.com/terraform/plugin/testing/acceptance-tests)

## Navigation

- **Previous**: [Advanced Features](advanced.md) - Actions and ephemeral resources
- **Up**: [Index](index.md) - Documentation home

---

*You've completed the terraform-plugin-framework documentation! Review [Index](index.md) for a complete overview.*
