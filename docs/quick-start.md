# Quick Start Guide

Get started building Terraform providers with terraform-plugin-framework.

## Installation

### Prerequisites

- **Go 1.24+** - Required for terraform-plugin-framework v1.17.0
- **Terraform 1.0+** - For testing your provider
- **Git** - For version control

### Install Framework

Add terraform-plugin-framework to your Go module:

```bash
go get github.com/hashicorp/terraform-plugin-framework@v1.17.0
```

### Recommended Tools

```bash
# Plugin testing framework
go get github.com/hashicorp/terraform-plugin-testing

# Plugin docs generator
go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest
```

## Your First Provider

### 1. Initialize Project

```bash
mkdir terraform-provider-example
cd terraform-provider-example
go mod init github.com/example/terraform-provider-example
```

### 2. Create Provider Struct

Create `provider.go`:

```go
package main

import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/provider"
    "github.com/hashicorp/terraform-plugin-framework/provider/schema"
    "github.com/hashicorp/terraform-plugin-framework/resource"
)

type exampleProvider struct {
    version string
}

func New(version string) func() provider.Provider {
    return func() provider.Provider {
        return &exampleProvider{
            version: version,
        }
    }
}

func (p *exampleProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "example"
    resp.Version = p.version
}

func (p *exampleProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Attributes: map[string]schema.Attribute{
            "endpoint": schema.StringAttribute{
                Optional: true,
            },
        },
    }
}

func (p *exampleProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    // Configure provider (read config, create API client, etc.)
}

func (p *exampleProvider) Resources(ctx context.Context) []func() resource.Resource {
    return []func() resource.Resource{
        // Register resources here
    }
}

func (p *exampleProvider) DataSources(ctx context.Context) []func() datasource.DataSource {
    return []func() datasource.DataSource{
        // Register data sources here
    }
}
```

### 3. Create Main Entry Point

Create `main.go`:

```go
package main

import (
    "context"
    "flag"
    "log"

    "github.com/hashicorp/terraform-plugin-framework/providerserver"
)

var (
    version string = "dev"
)

func main() {
    var debug bool

    flag.BoolVar(&debug, "debug", false, "set to true to run the provider with support for debuggers")
    flag.Parse()

    opts := providerserver.ServeOpts{
        Address: "registry.terraform.io/example/example",
        Debug:   debug,
    }

    err := providerserver.Serve(context.Background(), New(version), opts)
    if err != nil {
        log.Fatal(err.Error())
    }
}
```

### 4. Build and Test

```bash
# Build provider
go build -o terraform-provider-example

# Install locally for testing
mkdir -p ~/.terraform.d/plugins/registry.terraform.io/example/example/0.1.0/linux_amd64
cp terraform-provider-example ~/.terraform.d/plugins/registry.terraform.io/example/example/0.1.0/linux_amd64/

# Create test configuration
cat > main.tf <<EOF
terraform {
  required_providers {
    example = {
      source = "registry.terraform.io/example/example"
      version = "0.1.0"
    }
  }
}

provider "example" {
  endpoint = "https://api.example.com"
}
EOF

# Test provider
terraform init
terraform plan
```

## When to Use terraform-plugin-framework

### ✅ Use Framework When:

- **Building new providers** - Framework is the recommended SDK
- **Need complex schemas** - Rich type system with nested attributes
- **Custom validation** - Built-in validators plus custom validator support
- **Protocol v6 features** - Latest Terraform protocol capabilities
- **Type safety required** - Strong typing with compile-time checks

### ❌ Don't Use Framework When:

- **Maintaining existing SDK providers** - Migration requires significant effort
- **Protocol v5 only** - If you must support older Terraform versions (use terraform-plugin-go directly)

### Framework vs SDK Comparison

| Feature | Framework | SDK (Legacy) |
|---------|-----------|--------------|
| Protocol | v6 (latest) | v5 |
| Type System | Rich, extensible | Basic |
| Nested Schemas | Full support | Limited |
| Custom Types | Yes | No |
| Plan Modifiers | Yes | Limited |
| Validators | Built-in + custom | Manual |
| Status | ✅ Recommended | 🟡 Maintenance mode |

## Next Steps

### Core Concepts to Learn

1. **[Provider Implementation](provider.md)** - Provider interface, configuration, server setup
2. **[Resources](resources.md)** - CRUD operations, state management, import
3. **[Schema Design](schema.md)** - Attributes, blocks, nested structures
4. **[Type System](types.md)** - Framework types, conversions, null/unknown values

### Common Tasks

**Add a Resource:**
```go
// 1. Define resource type
type petResource struct {
    client *api.Client
}

// 2. Implement resource.Resource interface
func (r *petResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}

func (r *petResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    // Define schema
}

// 3. Implement CRUD methods
func (r *petResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // Create logic
}

// 4. Register in provider
func (p *exampleProvider) Resources(ctx context.Context) []func() resource.Resource {
    return []func() resource.Resource{
        func() resource.Resource { return &petResource{} },
    }
}
```

**Add Validation:**
```go
"name": schema.StringAttribute{
    Required: true,
    Validators: []validator.String{
        stringvalidator.LengthAtLeast(1),
        stringvalidator.LengthAtMost(100),
    },
},
```

**Add Plan Modifier:**
```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

## Essential Patterns

### Always Check Diagnostics

```go
func (r *petResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var data PetModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
    if resp.Diagnostics.HasError() {
        return  // ALWAYS return early if errors
    }

    // Continue with create logic...
}
```

### Handle Null and Unknown Values

```go
// Check before using
if !data.Name.IsNull() && !data.Name.IsUnknown() {
    name := data.Name.ValueString()
    // Use name
}
```

### Use Framework Types

```go
type PetModel struct {
    ID      types.String `tfsdk:"id"`
    Name    types.String `tfsdk:"name"`
    Age     types.Int64  `tfsdk:"age"`
    Active  types.Bool   `tfsdk:"active"`
}
```

## Resources

- **[HashiCorp Tutorial](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework)** - Official hands-on tutorial
- **[Scaffolding Template](https://github.com/hashicorp/terraform-provider-scaffolding-framework)** - Start from template
- **[Example Providers](https://github.com/hashicorp?q=terraform-provider&type=all)** - Real-world examples
- **[Plugin Testing Guide](https://developer.hashicorp.com/terraform/plugin/testing)** - Test your provider

## Navigation

- **Previous**: [Index](index.md) - Documentation overview
- **Next**: [Provider](provider.md) - Provider implementation details
- **Up**: [Index](index.md) - Documentation home

---

*Ready to dive deeper? Continue to [Provider Implementation](provider.md) to learn about provider configuration and setup.*
