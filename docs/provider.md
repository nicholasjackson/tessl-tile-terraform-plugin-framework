# Provider Implementation

Learn how to implement the provider interface, configure provider-level settings, and set up the provider server.

## Provider Interface

The `provider.Provider` interface is the core of your Terraform provider. It defines metadata, schema, configuration, and registers resources and data sources.

### Required Methods

```go
type Provider interface {
    // Metadata returns provider type name and version
    Metadata(context.Context, MetadataRequest, *MetadataResponse)

    // Schema defines provider configuration schema
    Schema(context.Context, SchemaRequest, *SchemaResponse)

    // Configure initializes provider (create API clients, etc.)
    Configure(context.Context, ConfigureRequest, *ConfigureResponse)

    // Resources returns all managed resources
    Resources(context.Context) []func() resource.Resource

    // DataSources returns all data sources
    DataSources(context.Context) []func() datasource.DataSource
}
```

### Optional Methods

```go
// Optional: Register provider functions (Terraform functions)
Functions(context.Context) []func() function.Function

// Optional: Register ephemeral resources (session-scoped)
EphemeralResources(context.Context) []func() ephemeral.EphemeralResource

// Optional: Register provider actions
Actions(context.Context) []func() action.Action
```

## Basic Provider Implementation

### Provider Struct

```go
package provider

import (
    "context"
    "os"

    "github.com/hashicorp/terraform-plugin-framework/datasource"
    "github.com/hashicorp/terraform-plugin-framework/provider"
    "github.com/hashicorp/terraform-plugin-framework/provider/schema"
    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure provider implements provider.Provider
var _ provider.Provider = &ExampleProvider{}

type ExampleProvider struct {
    version string
}

// New creates a provider factory function
func New(version string) func() provider.Provider {
    return func() provider.Provider {
        return &ExampleProvider{
            version: version,
        }
    }
}
```

### Metadata Method

Returns the provider type name used as prefix for resources and data sources.

```go
func (p *ExampleProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "example"
    resp.Version = p.version
}
```

**Usage in HCL:**
```hcl
terraform {
  required_providers {
    example = {
      source = "registry.terraform.io/example/example"
    }
  }
}

provider "example" {
  # Configuration here
}

# Resources use TypeName as prefix
resource "example_pet" "my_pet" {
  # example + "_" + resource name
}
```

### Schema Method

Defines provider-level configuration attributes.

```go
func (p *ExampleProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Example provider for managing resources",
        Attributes: map[string]schema.Attribute{
            "endpoint": schema.StringAttribute{
                Description: "API endpoint URL",
                Optional:    true,
            },
            "api_key": schema.StringAttribute{
                Description: "API authentication key",
                Optional:    true,
                Sensitive:   true,  // Masks in logs
            },
            "timeout": schema.Int64Attribute{
                Description: "API request timeout in seconds",
                Optional:    true,
            },
        },
    }
}
```

**Common Patterns:**
- Use `Optional: true` for provider config (allows environment variables)
- Use `Sensitive: true` for secrets (API keys, tokens)
- Use `Description` for Terraform documentation generation
- Provider config should allow both HCL and environment variable configuration

## Configure Method

Initializes the provider with configuration data. Create API clients, validate credentials, set up connections.

### Configuration Model

```go
type ExampleProviderModel struct {
    Endpoint types.String `tfsdk:"endpoint"`
    APIKey   types.String `tfsdk:"api_key"`
    Timeout  types.Int64  `tfsdk:"timeout"`
}
```

### Configure Implementation

```go
func (p *ExampleProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config ExampleProviderModel

    // Read configuration
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Handle unknown values (during plan phase)
    if config.Endpoint.IsUnknown() {
        resp.Diagnostics.AddWarning(
            "Unable to create client",
            "Cannot use unknown value for endpoint during plan",
        )
        return
    }

    // Apply defaults from environment if not set in config
    endpoint := config.Endpoint.ValueString()
    if config.Endpoint.IsNull() {
        endpoint = os.Getenv("EXAMPLE_ENDPOINT")
    }

    apiKey := config.APIKey.ValueString()
    if config.APIKey.IsNull() {
        apiKey = os.Getenv("EXAMPLE_API_KEY")
    }

    // Validate required configuration
    if endpoint == "" {
        resp.Diagnostics.AddError(
            "Missing API Endpoint",
            "The provider requires an endpoint. Set the endpoint in provider configuration or EXAMPLE_ENDPOINT environment variable.",
        )
    }

    if apiKey == "" {
        resp.Diagnostics.AddError(
            "Missing API Key",
            "The provider requires an API key. Set the api_key in provider configuration or EXAMPLE_API_KEY environment variable.",
        )
    }

    if resp.Diagnostics.HasError() {
        return
    }

    // Create API client
    timeout := 30
    if !config.Timeout.IsNull() {
        timeout = int(config.Timeout.ValueInt64())
    }

    client, err := NewClient(endpoint, apiKey, timeout)
    if err != nil {
        resp.Diagnostics.AddError(
            "Unable to create API client",
            "An error occurred creating the API client: "+err.Error(),
        )
        return
    }

    // Make client available to resources and data sources
    resp.DataSourceData = client
    resp.ResourceData = client
}
```

**Key Points:**
- Always check `resp.Diagnostics.HasError()` and return early
- Handle `IsUnknown()` during plan phase (return early with warning)
- Use environment variables as fallback for config values
- Validate required configuration before creating clients
- Store shared client in `resp.ResourceData` and `resp.DataSourceData`

## Registering Resources and Data Sources

### Resources Method

Returns factory functions for all managed resources.

```go
func (p *ExampleProvider) Resources(ctx context.Context) []func() resource.Resource {
    return []func() resource.Resource{
        NewPetResource,
        NewUserResource,
        NewGroupResource,
    }
}

// Resource factory function
func NewPetResource() resource.Resource {
    return &PetResource{}
}
```

### DataSources Method

Returns factory functions for all data sources.

```go
func (p *ExampleProvider) DataSources(ctx context.Context) []func() datasource.DataSource {
    return []func() datasource.DataSource{
        NewPetDataSource,
        NewPetsDataSource,  // Plural for listing
    }
}

func NewPetDataSource() datasource.DataSource {
    return &PetDataSource{}
}
```

## Resource and Data Source Configuration

Resources and data sources can access provider-configured data via the `Configure` method.

### Resource Configure Method

```go
type PetResource struct {
    client *Client
}

func (r *PetResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
    // Always check ProviderData is set
    if req.ProviderData == nil {
        return
    }

    client, ok := req.ProviderData.(*Client)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Resource Configure Type",
            fmt.Sprintf("Expected *Client, got: %T", req.ProviderData),
        )
        return
    }

    r.client = client
}
```

**Pattern:**
1. Provider's `Configure` method sets `resp.ResourceData`
2. Framework calls resource's `Configure` method with that data
3. Resource type-asserts and stores the client

## Provider Server Setup

### Main Function

```go
package main

import (
    "context"
    "flag"
    "log"

    "github.com/hashicorp/terraform-plugin-framework/providerserver"
    "github.com/example/terraform-provider-example/internal/provider"
)

var (
    version string = "dev"
)

func main() {
    var debug bool

    flag.BoolVar(&debug, "debug", false, "set to true to run the provider with support for debuggers")
    flag.Parse()

    opts := providerserver.ServeOpts{
        // Provider address in Terraform registry format
        Address: "registry.terraform.io/example/example",
        Debug:   debug,
    }

    err := providerserver.Serve(context.Background(), provider.New(version), opts)
    if err != nil {
        log.Fatal(err.Error())
    }
}
```

### Debug Mode

For debugging with Delve or other debuggers:

```bash
# Start provider in debug mode
go run main.go -debug

# Output will show TF_REATTACH_PROVIDERS value
# Set environment variable in another terminal:
export TF_REATTACH_PROVIDERS='{"registry.terraform.io/example/example":{"Protocol":"grpc","ProtocolVersion":6,"Pid":12345,"Test":true,"Addr":{"Network":"unix","String":"/tmp/plugin123"}}}'

# Run Terraform commands
terraform plan
```

## Protocol Version

The framework uses protocol version 6 (latest):

```go
// Automatically handled by providerserver.Serve
// No explicit protocol version configuration needed
```

**Protocol v6 features:**
- Improved type system
- Deferred actions support
- Ephemeral resources
- Functions
- Client-managed state

## Common Patterns

### Multiple Provider Instances

Support multiple configurations of the same provider:

```hcl
provider "example" {
  alias    = "west"
  endpoint = "https://api.west.example.com"
}

provider "example" {
  alias    = "east"
  endpoint = "https://api.east.example.com"
}

resource "example_pet" "west_pet" {
  provider = example.west
  name     = "Fluffy"
}

resource "example_pet" "east_pet" {
  provider = example.east
  name     = "Spot"
}
```

Each provider instance calls `Configure` independently with its own config.

### Shared Client Configuration

Store common configuration in provider, use in resources:

```go
type ProviderData struct {
    Client    *APIClient
    UserAgent string
    RetryMax  int
}

// In provider Configure:
data := &ProviderData{
    Client:    client,
    UserAgent: fmt.Sprintf("terraform-provider-example/%s", p.version),
    RetryMax:  3,
}
resp.ResourceData = data

// In resource Configure:
data, ok := req.ProviderData.(*ProviderData)
r.data = data
```

### Testing Provider

```go
func TestProvider(t *testing.T) {
    provider := New("test")()

    // Test Metadata
    metadataResp := &provider.MetadataResponse{}
    provider.Metadata(context.Background(), provider.MetadataRequest{}, metadataResp)

    require.Equal(t, "example", metadataResp.TypeName)
    require.Equal(t, "test", metadataResp.Version)
}
```

See [Testing](testing.md) for comprehensive testing patterns.

## External References

- [Provider Interface](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/provider#Provider)
- [Provider Server](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/providerserver)
- [HashiCorp Provider Tutorial](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework/providers-plugin-framework-provider)

## Navigation

- **Previous**: [Quick Start](quick-start.md) - Getting started guide
- **Next**: [Resources](resources.md) - Resource implementation
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Resources](resources.md) to learn about implementing CRUD operations and state management.*
