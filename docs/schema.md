# Schema System

Design resource and data source schemas with attributes, blocks, nested structures, and modifiers.

## Overview

Schemas define the structure of resources and data sources. They specify:
- **Attributes**: Individual configuration values
- **Blocks**: Nested configuration sections
- **Constraints**: Required, optional, computed
- **Validation**: Validators and plan modifiers
- **Documentation**: Descriptions for generated docs

## Basic Schema Structure

### Resource Schema

```go
func (r *PetResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Manages a pet resource",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Unique identifier",
                Computed:    true,
            },
            "name": schema.StringAttribute{
                Description: "Pet name",
                Required:    true,
            },
        },
    }
}
```

### Data Source Schema

```go
func (d *PetDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Fetches pet data",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Pet ID to lookup",
                Required:    true,
            },
            "name": schema.StringAttribute{
                Description: "Pet name",
                Computed:    true,
            },
        },
    }
}
```

## Attribute Types

### Primitive Types

```go
Attributes: map[string]schema.Attribute{
    // String
    "name": schema.StringAttribute{
        Required: true,
    },

    // Int64
    "age": schema.Int64Attribute{
        Optional: true,
    },

    // Float64
    "weight": schema.Float64Attribute{
        Optional: true,
    },

    // Bool
    "active": schema.BoolAttribute{
        Optional: true,
    },

    // Number (arbitrary precision)
    "price": schema.NumberAttribute{
        Optional: true,
    },
}
```

### Collection Types

```go
Attributes: map[string]schema.Attribute{
    // List of strings
    "tags": schema.ListAttribute{
        ElementType: types.StringType,
        Optional:    true,
    },

    // Set of strings
    "roles": schema.SetAttribute{
        ElementType: types.StringType,
        Optional:    true,
    },

    // Map of string to string
    "labels": schema.MapAttribute{
        ElementType: types.StringType,
        Optional:    true,
    },
}
```

### Nested Attributes

```go
Attributes: map[string]schema.Attribute{
    // Single nested object
    "address": schema.SingleNestedAttribute{
        Optional: true,
        Attributes: map[string]schema.Attribute{
            "street": schema.StringAttribute{
                Required: true,
            },
            "city": schema.StringAttribute{
                Required: true,
            },
            "zipcode": schema.StringAttribute{
                Optional: true,
            },
        },
    },

    // List of nested objects
    "contacts": schema.ListNestedAttribute{
        Optional: true,
        NestedObject: schema.NestedAttributeObject{
            Attributes: map[string]schema.Attribute{
                "name": schema.StringAttribute{
                    Required: true,
                },
                "email": schema.StringAttribute{
                    Required: true,
                },
                "phone": schema.StringAttribute{
                    Optional: true,
                },
            },
        },
    },

    // Set of nested objects
    "permissions": schema.SetNestedAttribute{
        Optional: true,
        NestedObject: schema.NestedAttributeObject{
            Attributes: map[string]schema.Attribute{
                "resource": schema.StringAttribute{
                    Required: true,
                },
                "action": schema.StringAttribute{
                    Required: true,
                },
            },
        },
    },

    // Map of nested objects
    "metadata": schema.MapNestedAttribute{
        Optional: true,
        NestedObject: schema.NestedAttributeObject{
            Attributes: map[string]schema.Attribute{
                "value": schema.StringAttribute{
                    Required: true,
                },
                "description": schema.StringAttribute{
                    Optional: true,
                },
            },
        },
    },
}
```

### Dynamic Type

For values with unknown structure at schema definition time:

```go
"config": schema.DynamicAttribute{
    Description: "Arbitrary configuration",
    Optional:    true,
},
```

See [Type System](types.md) for details on working with dynamic types.

## Attribute Constraints

### Required, Optional, Computed

```go
Attributes: map[string]schema.Attribute{
    // Required: Must be set by user
    "name": schema.StringAttribute{
        Required: true,
    },

    // Optional: May be set by user
    "description": schema.StringAttribute{
        Optional: true,
    },

    // Computed: Set by provider (read-only for user)
    "id": schema.StringAttribute{
        Computed: true,
    },

    // Optional + Computed: User can set or provider computes
    "status": schema.StringAttribute{
        Optional: true,
        Computed: true,
    },
}
```

**Rules:**
- Exactly one of `Required`, `Optional`, `Computed` must be true
- Can combine `Optional` and `Computed`
- Cannot combine `Required` and `Computed`

### Sensitive

Mark attributes as sensitive to mask in logs:

```go
"api_key": schema.StringAttribute{
    Required:  true,
    Sensitive: true,  // Masked as (sensitive value) in logs
},
```

### Deprecated

Mark attributes as deprecated:

```go
"old_field": schema.StringAttribute{
    Optional:         true,
    DeprecationMessage: "Use new_field instead. old_field will be removed in v2.0.0",
},
```

## Default Values

Provide default values for optional attributes:

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/defaults"

"timeout": schema.Int64Attribute{
    Optional: true,
    Computed: true,
    Default:  int64default.StaticInt64(30),
},

"enabled": schema.BoolAttribute{
    Optional: true,
    Computed: true,
    Default:  booldefault.StaticBool(true),
},

"environment": schema.StringAttribute{
    Optional: true,
    Computed: true,
    Default:  stringdefault.StaticString("production"),
},
```

### Custom Defaults

```go
type EnvironmentDefault struct{}

func (d EnvironmentDefault) Description(ctx context.Context) string {
    return "Defaults to 'dev' in development, 'prod' in production"
}

func (d EnvironmentDefault) MarkdownDescription(ctx context.Context) string {
    return "Defaults to `dev` in development, `prod` in production"
}

func (d EnvironmentDefault) DefaultString(ctx context.Context, req defaults.StringRequest, resp *defaults.StringResponse) {
    if os.Getenv("APP_ENV") == "production" {
        resp.PlanValue = types.StringValue("prod")
    } else {
        resp.PlanValue = types.StringValue("dev")
    }
}

// Use in schema
"environment": schema.StringAttribute{
    Optional: true,
    Computed: true,
    Default:  EnvironmentDefault{},
},
```

## Validators

Add validation logic to attributes:

```go
import "github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
import "github.com/hashicorp/terraform-plugin-framework-validators/int64validator"

Attributes: map[string]schema.Attribute{
    "name": schema.StringAttribute{
        Required: true,
        Validators: []validator.String{
            stringvalidator.LengthAtLeast(1),
            stringvalidator.LengthAtMost(100),
        },
    },

    "port": schema.Int64Attribute{
        Required: true,
        Validators: []validator.Int64{
            int64validator.Between(1, 65535),
        },
    },

    "protocol": schema.StringAttribute{
        Required: true,
        Validators: []validator.String{
            stringvalidator.OneOf("http", "https", "tcp", "udp"),
        },
    },
}
```

See [Validators](validators.md) for comprehensive validation patterns.

## Plan Modifiers

Control plan behavior for computed attributes:

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"

Attributes: map[string]schema.Attribute{
    "id": schema.StringAttribute{
        Computed: true,
        PlanModifiers: []planmodifier.String{
            // Use state value if unknown during plan
            stringplanmodifier.UseStateForUnknown(),
        },
    },

    "region": schema.StringAttribute{
        Required: true,
        PlanModifiers: []planmodifier.String{
            // Require replacement if region changes
            stringplanmodifier.RequiresReplace(),
        },
    },
}
```

See [Plan Modifiers](plan-modifiers.md) for details.

## Blocks

Blocks are repeatable nested configuration sections. Use when users need multiple instances:

```go
func (r *ServerResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Blocks: map[string]schema.Block{
            "disk": schema.ListNestedBlock{
                Description: "Disks attached to server",
                NestedObject: schema.NestedBlockObject{
                    Attributes: map[string]schema.Attribute{
                        "name": schema.StringAttribute{
                            Required: true,
                        },
                        "size": schema.Int64Attribute{
                            Required: true,
                        },
                        "type": schema.StringAttribute{
                            Optional: true,
                        },
                    },
                },
            },
        },
    }
}
```

**Usage in HCL:**
```hcl
resource "example_server" "web" {
  name = "web-server"

  disk {
    name = "boot"
    size = 50
    type = "ssd"
  }

  disk {
    name = "data"
    size = 500
    type = "hdd"
  }
}
```

### Block Types

```go
Blocks: map[string]schema.Block{
    // List: Ordered, repeatable
    "volume": schema.ListNestedBlock{
        NestedObject: schema.NestedBlockObject{
            Attributes: map[string]schema.Attribute{
                "size": schema.Int64Attribute{Required: true},
            },
        },
    },

    // Set: Unordered, repeatable, unique
    "tag": schema.SetNestedBlock{
        NestedObject: schema.NestedBlockObject{
            Attributes: map[string]schema.Attribute{
                "key": schema.StringAttribute{Required: true},
                "value": schema.StringAttribute{Required: true},
            },
        },
    },

    // Single: Non-repeatable
    "logging": schema.SingleNestedBlock{
        Attributes: map[string]schema.Attribute{
            "enabled": schema.BoolAttribute{Required: true},
            "level": schema.StringAttribute{Optional: true},
        },
    },
}
```

### Blocks vs Nested Attributes

| Feature | Nested Attributes | Blocks |
|---------|-------------------|--------|
| HCL Syntax | `attr = { ... }` | `block { ... }` |
| Repetition | List/Set/Map attribute | Block repetition |
| Use Case | Simple nesting | Complex repeatable config |
| Assignability | Can assign from variables | Cannot assign from variables |

**Use nested attributes** for simple nested data:
```hcl
resource "example_server" "web" {
  config = {
    memory = 4096
    cpus   = 2
  }
}
```

**Use blocks** for repeatable configuration:
```hcl
resource "example_server" "web" {
  disk {
    size = 50
  }
  disk {
    size = 100
  }
}
```

## Schema Documentation

### Descriptions

```go
resp.Schema = schema.Schema{
    Description: "Manages a server instance",
    MarkdownDescription: "Manages a server instance.\n\n" +
        "Servers are virtual machines with configurable resources.",

    Attributes: map[string]schema.Attribute{
        "name": schema.StringAttribute{
            Description: "Server name",
            MarkdownDescription: "Server name. Must be unique within the account.",
            Required: true,
        },
    },
}
```

- `Description`: Plain text for CLI help
- `MarkdownDescription`: Markdown for generated documentation

### Version

Indicate schema version for compatibility tracking:

```go
resp.Schema = schema.Schema{
    Version: 1,  // Increment when making schema changes
    // ...
}
```

## Working with Schema in Code

### Reading Configuration

```go
type ServerModel struct {
    Name    types.String `tfsdk:"name"`
    Disks   []DiskModel  `tfsdk:"disk"`
}

type DiskModel struct {
    Name types.String `tfsdk:"name"`
    Size types.Int64  `tfsdk:"size"`
    Type types.String `tfsdk:"type"`
}

func (r *ServerResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan ServerModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Access values
    name := plan.Name.ValueString()

    // Iterate blocks
    for _, disk := range plan.Disks {
        diskName := disk.Name.ValueString()
        diskSize := disk.Size.ValueInt64()
        // ...
    }
}
```

### Setting State

```go
func (r *ServerResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // ... create server via API ...

    state := ServerModel{
        ID:   types.StringValue(server.ID),
        Name: types.StringValue(server.Name),
        Disks: make([]DiskModel, len(server.Disks)),
    }

    for i, disk := range server.Disks {
        state.Disks[i] = DiskModel{
            Name: types.StringValue(disk.Name),
            Size: types.Int64Value(disk.Size),
            Type: types.StringValue(disk.Type),
        }
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

## Common Patterns

### Computed ID

```go
"id": schema.StringAttribute{
    Description: "Unique identifier",
    Computed:    true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Immutable Attribute

```go
"region": schema.StringAttribute{
    Description: "Deployment region (immutable)",
    Required:    true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),
    },
},
```

### Optional with Computed Default

```go
"status": schema.StringAttribute{
    Description: "Server status (defaults to 'running')",
    Optional:    true,
    Computed:    true,
    Default:     stringdefault.StaticString("running"),
},
```

### Sensitive Credentials

```go
"password": schema.StringAttribute{
    Description: "Admin password",
    Required:    true,
    Sensitive:   true,
},
```

### Tags Map

```go
"tags": schema.MapAttribute{
    Description: "Resource tags",
    ElementType: types.StringType,
    Optional:    true,
},
```

**Usage:**
```hcl
resource "example_server" "web" {
  name = "web-1"
  tags = {
    environment = "production"
    team        = "platform"
  }
}
```

### Nested Configuration

```go
"network": schema.SingleNestedAttribute{
    Description: "Network configuration",
    Required:    true,
    Attributes: map[string]schema.Attribute{
        "vpc_id": schema.StringAttribute{
            Required: true,
        },
        "subnet_id": schema.StringAttribute{
            Required: true,
        },
        "security_groups": schema.ListAttribute{
            ElementType: types.StringType,
            Optional:    true,
        },
    },
},
```

## Schema Migration

### Adding Attributes

Safe to add optional or computed attributes:

```go
// Version 1
Attributes: map[string]schema.Attribute{
    "name": schema.StringAttribute{Required: true},
}

// Version 2 - safe
Attributes: map[string]schema.Attribute{
    "name": schema.StringAttribute{Required: true},
    "description": schema.StringAttribute{Optional: true},  // New optional
}
```

### Removing Attributes

Mark as deprecated first:

```go
// Version 2
"old_field": schema.StringAttribute{
    Optional:           true,
    DeprecationMessage: "Use new_field instead",
},

// Version 3 - remove after grace period
// (remove old_field from schema)
```

### Changing Constraints

Avoid changing required/optional/computed:

```go
// BAD: Breaks existing configs
"name": schema.StringAttribute{
    Required: true,  // Was: Optional: true
}

// GOOD: Add new attribute
"name_v2": schema.StringAttribute{
    Required: true,
},
"name": schema.StringAttribute{
    Optional:           true,
    DeprecationMessage: "Use name_v2",
},
```

## External References

- [Schema Package](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/resource/schema)
- [Schema Design Guide](https://developer.hashicorp.com/terraform/plugin/framework/schemas)
- [Attribute Types](https://developer.hashicorp.com/terraform/plugin/framework/schemas#attribute-types)

## Navigation

- **Previous**: [Data Sources](data-sources.md) - Data source implementation
- **Next**: [Type System](types.md) - Framework types and conversions
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Type System](types.md) to learn about framework types, conversions, and null/unknown handling.*
