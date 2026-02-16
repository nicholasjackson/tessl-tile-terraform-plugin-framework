# Testing

Test Terraform providers with unit tests (testify/require) and acceptance tests (terraform-plugin-testing).

## Overview

Provider testing includes:
- **Unit Tests**: Test individual functions, validators, plan modifiers with testify/require
- **Acceptance Tests**: Full integration tests using terraform-plugin-testing
- **Mock-Based Tests**: Use mockery for mocking API clients

**Follow Go best practices:** Use testify/require, avoid table-driven tests, separate positive and negative tests.

## Unit Testing

### Testing with testify/require

```go
import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestResourceMetadata(t *testing.T) {
    resource := NewPetResource()

    req := resource.MetadataRequest{
        ProviderTypeName: "example",
    }
    resp := &resource.MetadataResponse{}

    resource.Metadata(context.Background(), req, resp)

    require.Equal(t, "example_pet", resp.TypeName)
}

func TestResourceMetadata_WrongTypeName(t *testing.T) {
    resource := NewPetResource()

    req := resource.MetadataRequest{
        ProviderTypeName: "other",
    }
    resp := &resource.MetadataResponse{}

    resource.Metadata(context.Background(), req, resp)

    require.NotEqual(t, "example_pet", resp.TypeName)
    require.Equal(t, "other_pet", resp.TypeName)
}
```

**Key points:**
- One test function per scenario (no table-driven tests)
- Use `require` for assertions (stops test on failure)
- Separate positive and negative tests

### Testing Resources with Mocks

Use mockery to generate mocks for API clients:

```bash
# Generate mocks
mockery --name=APIClient --dir=./internal/client --output=./internal/client/mocks
```

```go
func TestPetResource_Create(t *testing.T) {
    mockClient := client.NewMockAPIClient(t)
    mockClient.On("CreatePet", mock.Anything, &client.CreatePetRequest{
        Name:    "Fluffy",
        Species: "cat",
    }).Return(&client.Pet{
        ID:      "pet-123",
        Name:    "Fluffy",
        Species: "cat",
        Age:     3,
    }, nil)

    resource := &PetResource{client: mockClient}

    // Create plan with test data
    plan := PetResourceModel{
        Name:    types.StringValue("Fluffy"),
        Species: types.StringValue("cat"),
    }

    req := resource.CreateRequest{
        Plan: tfsdk.Plan{
            Raw:    planRawValue,
            Schema: resourceSchema,
        },
    }
    resp := &resource.CreateResponse{
        State: tfsdk.State{
            Schema: resourceSchema,
        },
    }

    resource.Create(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
    mockClient.AssertExpectations(t)

    var state PetResourceModel
    resp.State.Get(context.Background(), &state)
    require.Equal(t, "pet-123", state.ID.ValueString())
    require.Equal(t, "Fluffy", state.Name.ValueString())
}

func TestPetResource_Create_APIError(t *testing.T) {
    mockClient := client.NewMockAPIClient(t)
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(nil, errors.New("API error"))

    resource := &PetResource{client: mockClient}

    req := resource.CreateRequest{
        Plan: tfsdk.Plan{
            Raw:    planRawValue,
            Schema: resourceSchema,
        },
    }
    resp := &resource.CreateResponse{
        State: tfsdk.State{
            Schema: resourceSchema,
        },
    }

    resource.Create(context.Background(), req, resp)

    require.True(t, resp.Diagnostics.HasError())
    require.Contains(t, resp.Diagnostics.Errors()[0].Detail(), "API error")
}
```

### Testing Validators

```go
func TestEmailValidator(t *testing.T) {
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

### Testing Functions

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

## Acceptance Testing

Acceptance tests use `terraform-plugin-testing` to run real Terraform operations against your provider.

### Setup

```go
import (
    "testing"
    "github.com/hashicorp/terraform-plugin-testing/helper/resource"
)

func TestAccPetResource(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Create and Read testing
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("example_pet.test", "species", "cat"),
                    resource.TestCheckResourceAttrSet("example_pet.test", "id"),
                ),
            },
            // ImportState testing
            {
                ResourceName:      "example_pet.test",
                ImportState:       true,
                ImportStateVerify: true,
            },
            // Update and Read testing
            {
                Config: testAccPetResourceConfig("Fluffy Updated", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy Updated"),
                ),
            },
            // Delete testing automatically occurs at end
        },
    })
}

func testAccPetResourceConfig(name, species string) string {
    return fmt.Sprintf(`
resource "example_pet" "test" {
  name    = %[1]q
  species = %[2]q
}
`, name, species)
}
```

### Provider Factories

```go
var testAccProtoV6ProviderFactories = map[string]func() (tfprotov6.ProviderServer, error){
    "example": providerserver.NewProtocol6WithError(New("test")()),
}

func testAccPreCheck(t *testing.T) {
    // Check required environment variables
    if v := os.Getenv("EXAMPLE_API_KEY"); v == "" {
        t.Fatal("EXAMPLE_API_KEY must be set for acceptance tests")
    }
}
```

### Acceptance Test Patterns

#### Create and Read

```go
{
    Config: testAccPetResourceConfig("Fluffy", "cat"),
    Check: resource.ComposeAggregateTestCheckFunc(
        resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
        resource.TestCheckResourceAttr("example_pet.test", "species", "cat"),
        resource.TestCheckResourceAttrSet("example_pet.test", "id"),
        resource.TestCheckResourceAttrSet("example_pet.test", "created_at"),
    ),
},
```

#### Update

```go
{
    Config: testAccPetResourceConfig("Fluffy Updated", "cat"),
    Check: resource.ComposeAggregateTestCheckFunc(
        resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy Updated"),
        // ID should not change on update
        resource.TestCheckResourceAttrPair(
            "example_pet.test", "id",
            "example_pet.test", "id",
        ),
    ),
},
```

#### Import

```go
{
    ResourceName:      "example_pet.test",
    ImportState:       true,
    ImportStateVerify: true,
    // Ignore computed fields that can't be imported
    ImportStateVerifyIgnore: []string{"created_at"},
},
```

#### ExpectError

```go
{
    Config: testAccPetResourceConfig_Invalid(),
    ExpectError: regexp.MustCompile(`Invalid species`),
},
```

#### Destroy

```go
{
    Config: testAccPetResourceConfig("Fluffy", "cat"),
},
{
    Config:  testAccEmptyConfig(),
    Destroy: true,
},
```

### Data Source Acceptance Tests

```go
func TestAccPetDataSource(t *testing.T) {
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

### Function Acceptance Tests

```go
func TestAccBase64EncodeFunction(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config: testAccBase64EncodeFunctionConfig(),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckOutput("encoded", "aGVsbG8="),
                ),
            },
        },
    })
}

func testAccBase64EncodeFunctionConfig() string {
    return `
output "encoded" {
  value = provider::example::base64_encode("hello")
}
`
}
```

## Testing Best Practices

### Separate Positive and Negative Tests

```go
// GOOD: Separate test functions
func TestResourceCreate(t *testing.T) {
    // Test successful creation
}

func TestResourceCreate_APIError(t *testing.T) {
    // Test API error handling
}

func TestResourceCreate_InvalidInput(t *testing.T) {
    // Test validation error
}

// BAD: Combined in table-driven test (avoid this)
func TestResourceCreate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        // Don't do this
    }
    // ...
}
```

### Use require for Assertions

```go
// GOOD: Use require (stops on failure)
require.Equal(t, expected, actual)
require.NoError(t, err)
require.True(t, condition)

// BAD: Use assert (continues on failure)
assert.Equal(t, expected, actual)  // Avoid
```

### Test Coverage

Ensure tests cover:
- All CRUD operations
- Import functionality
- Validation logic
- Error handling
- Edge cases (null, unknown, empty values)
- Plan modifiers behavior
- Cross-attribute validation

### Test Organization

```
provider_test.go         # Provider tests
resource_pet_test.go     # Pet resource tests
datasource_pet_test.go   # Pet data source tests
validators_test.go       # Validator tests
planmodifiers_test.go    # Plan modifier tests
function_base64_test.go  # Function tests
```

## Mocking Patterns

### API Client Mock

```go
type MockAPIClient struct {
    mock.Mock
}

func (m *MockAPIClient) CreatePet(ctx context.Context, req *CreatePetRequest) (*Pet, error) {
    args := m.Called(ctx, req)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*Pet), args.Error(1)
}

// Use in tests
mockClient := &MockAPIClient{}
mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(&Pet{
    ID:   "pet-123",
    Name: "Fluffy",
}, nil)
```

### Mock Setup Helpers

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
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(&Pet{}, nil)

    // Test code...
    // AssertExpectations called automatically via t.Cleanup
}
```

## Running Tests

```bash
# Run unit tests
go test ./...

# Run acceptance tests
TF_ACC=1 go test ./... -v

# Run specific test
go test -run TestAccPetResource ./...

# Run with coverage
go test -cover ./...

# Verbose output
go test -v ./...
```

## Test Helpers

### Create Test Configuration

```go
func testAccResourceConfig(attrs map[string]string) string {
    config := `
resource "example_pet" "test" {
`
    for k, v := range attrs {
        config += fmt.Sprintf("  %s = %q\n", k, v)
    }
    config += "}\n"
    return config
}
```

### Check Functions

```go
func testAccCheckPetExists(resourceName string) resource.TestCheckFunc {
    return func(s *terraform.State) error {
        rs, ok := s.RootModule().Resources[resourceName]
        if !ok {
            return fmt.Errorf("Not found: %s", resourceName)
        }

        if rs.Primary.ID == "" {
            return fmt.Errorf("Pet ID is not set")
        }

        // Verify pet exists via API
        _, err := testAccProvider.client.GetPet(context.Background(), rs.Primary.ID)
        return err
    }
}
```

## External References

- [Testing Guide](https://developer.hashicorp.com/terraform/plugin/framework/testing)
- [terraform-plugin-testing](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-testing)
- [Acceptance Tests](https://developer.hashicorp.com/terraform/plugin/testing/acceptance-tests)

## Navigation

- **Previous**: [Advanced Features](advanced.md) - Actions and ephemeral resources
- **Up**: [Index](index.md) - Documentation home

---

*You've completed the terraform-plugin-framework documentation! Review [Index](index.md) for a complete overview.*
