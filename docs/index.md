# Terraform Plugin Framework Guide

Comprehensive documentation for building Terraform providers with `github.com/hashicorp/terraform-plugin-framework` (v1.17.0).

## What is terraform-plugin-framework?

terraform-plugin-framework is the **recommended** Go SDK for building Terraform providers. It provides a structured, type-safe approach to implementing providers, resources, data sources, functions, and other Terraform capabilities.

**Key Benefits**:
- **Type Safety**: Strong typing throughout with compile-time checks
- **Modern Architecture**: Protocol version 6 support (latest Terraform protocol)
- **Flexible Schema System**: Rich attribute types, nested structures, validation
- **Testing Support**: Integration with terraform-plugin-testing for acceptance tests
- **Extensibility**: Custom types, validators, plan modifiers

**When to Use**:
- Building new Terraform providers (recommended)
- Need for complex nested schemas
- Requirement for custom types or validation logic
- Protocol version 6 features needed

**When NOT to Use**:
- Maintaining existing terraform-plugin-sdk providers (migration effort required)
- Very simple providers (framework may be overkill, but still recommended)

## Version Compatibility

- **Framework**: v1.17.0 (covered by this documentation)
- **Go**: 1.24+ required
- **Terraform**: 1.0+ (protocol v6 support)
- **Testing**: terraform-plugin-testing v1.0+

## Architecture Overview

```
Provider (metadata, config, resources, data sources, functions)
├── Resources (CRUD operations, state management)
│   └── Schema (attributes, validators, plan modifiers)
├── Data Sources (read operations)
│   └── Schema (attributes, validators)
├── Functions (custom Terraform functions)
└── Actions & Ephemeral Resources (session-scoped operations)
```

**Protocol Flow**:
1. Terraform CLI starts provider as plugin subprocess
2. Provider registers capabilities (resources, data sources, functions)
3. Terraform calls provider methods via gRPC protocol
4. Provider performs operations and returns results with diagnostics

## Documentation Structure

This documentation is organized by framework capability:

### Getting Started
- [Quick Start](quick-start.md) - Installation, first provider, when to use

### Core Implementation
- [Provider](provider.md) - Provider interface, configuration, server setup
- [Resources](resources.md) - Resource CRUD, state management, import, lifecycle
- [Data Sources](data-sources.md) - Data source implementation, read patterns

### Schema & Types
- [Schema System](schema.md) - Attributes, blocks, nesting, computed vs required
- [Type System](types.md) - Framework types, conversions, null/unknown handling
- [Validators](validators.md) - Built-in validators, custom validators, cross-attribute
- [Plan Modifiers](plan-modifiers.md) - UseStateForUnknown, RequiresReplace, custom

### Advanced Features
- [Functions](functions.md) - Provider functions, parameters, returns, HCL usage
- [Advanced](advanced.md) - Actions and ephemeral resources

### Testing & Best Practices
- [Testing](testing.md) - Unit tests (testify/require), acceptance tests, patterns

### Rules & Steering
The tile includes best practices rules (automatically loaded by agents):
- **Diagnostics**: Always check diagnostics before proceeding
- **State Management**: State consistency, UseStateForUnknown patterns
- **Schema Design**: Schema design patterns, attribute modifiers
- **Testing Standards**: testify/require requirements, test organization
- **Common Pitfalls**: Consolidated gotchas from all areas

## Common Patterns

### Resource Implementation Pattern
```go
// 1. Define resource type implementing resource.Resource
type PetResource struct {
    client *api.Client
}

// 2. Implement required methods
func (r *PetResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}

func (r *PetResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    // Define schema with attributes
}

func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // Implement create logic
    // ALWAYS check resp.Diagnostics.HasError()
}

// Similar for Read, Update, Delete
```

**Key Points**:
- Always check `resp.Diagnostics.HasError()` after operations
- Use framework types (`types.String`, `types.Int64`, etc.) for attributes
- State management via `req.State.Get()` and `resp.State.Set()`
- Return early if diagnostics has errors

### Schema Definition Pattern
```go
schema.Schema{
    Attributes: map[string]schema.Attribute{
        "id": schema.StringAttribute{
            Computed: true,
            PlanModifiers: []planmodifier.String{
                stringplanmodifier.UseStateForUnknown(),
            },
        },
        "name": schema.StringAttribute{
            Required: true,
            Validators: []validator.String{
                stringvalidator.LengthAtLeast(1),
            },
        },
    },
}
```

**Key Points**:
- `Required`, `Optional`, `Computed` determine attribute behavior
- Use `UseStateForUnknown()` for computed attributes in Create
- Add validators to enforce constraints
- Use plan modifiers to control planning behavior

## Common Pitfalls

⚠️ **Not Checking Diagnostics**: Always check `resp.Diagnostics.HasError()` before proceeding. Continuing after errors leads to panics.

⚠️ **Missing UseStateForUnknown**: Computed attributes without `UseStateForUnknown()` in Create operations show as "known after apply" unnecessarily, causing unnecessary replaces.

⚠️ **Type Conversion Errors**: Framework types (`types.String`) are not Go primitives. Use `.ValueString()`, `.ValueInt64()`, etc. for conversion. Check `.IsNull()` and `.IsUnknown()` first.

⚠️ **State Management**: Forgetting to call `resp.State.Set()` at the end of CRUD operations means state isn't saved, causing Terraform to think resource doesn't exist.

⚠️ **Null vs Unknown**: Null = explicitly no value (set to `null`). Unknown = value not yet known (depends on another resource). Handle both cases.

See [Rules](../rules/) directory for comprehensive pitfalls and best practices.

## External Resources

### Official Documentation
- [HashiCorp Developer Docs](https://developer.hashicorp.com/terraform/plugin/framework)
- [Package Reference](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework)
- [Scaffolding Template](https://github.com/hashicorp/terraform-provider-scaffolding-framework)
- [Plugin Testing](https://github.com/hashicorp/terraform-plugin-testing)

### Community
- [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-providers/)
- [Terraform Provider Development Program](https://www.hashicorp.com/partners/become-a-partner)

### Related Tiles
- **Go Best Practices** - General Go patterns (TDD, testify/require, mockery)
- Reference for general Go idioms, this tile focuses on terraform-plugin-framework specifics

## Quick Links

| Topic | Documentation |
|-------|---------------|
| First Provider | [Quick Start](quick-start.md) |
| Provider Setup | [Provider](provider.md) |
| Resource CRUD | [Resources](resources.md) |
| Schema Design | [Schema System](schema.md) |
| Type System | [Type System](types.md) |
| Validation | [Validators](validators.md) |
| Plan Modifiers | [Plan Modifiers](plan-modifiers.md) |
| Testing | [Testing](testing.md) |

## Navigation

- **Next**: [Quick Start](quick-start.md) - Get started building your first provider
- **Up**: [README](../README.md) - Tile overview and installation

---

*This documentation covers terraform-plugin-framework v1.17.0. For the latest version, see [pkg.go.dev](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework).*
