# Schema Design Best Practices

Design clear, consistent schemas with proper constraints and modifiers.

## Core Principles

1. **Use correct attribute constraints** (Required, Optional, Computed)
2. **Add descriptions** for generated documentation
3. **Apply appropriate validators** for data integrity
4. **Use plan modifiers** to control Terraform behavior
5. **Mark sensitive attributes** to prevent exposure

## Attribute Constraints

### Required Attributes

User must provide value:

```go
"name": schema.StringAttribute{
    Required:    true,
    Description: "Resource name",
},
```

### Optional Attributes

User may provide value:

```go
"description": schema.StringAttribute{
    Optional:    true,
    Description: "Resource description",
},
```

### Computed Attributes

Provider sets value (read-only):

```go
"id": schema.StringAttribute{
    Computed:    true,
    Description: "Unique identifier",
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Optional + Computed

User can provide or provider computes:

```go
"status": schema.StringAttribute{
    Optional:    true,
    Computed:    true,
    Description: "Resource status (defaults to 'active')",
    Default:     stringdefault.StaticString("active"),
},
```

**Rules:**
- Exactly one of `Required`, `Optional`, `Computed` must be true
- Can combine `Optional` + `Computed`
- Cannot combine `Required` + `Computed`

## Required Modifiers

### IDs: UseStateForUnknown

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Immutable Fields: RequiresReplace

```go
"region": schema.StringAttribute{
    Required:    true,
    Description: "Deployment region (immutable)",
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),
    },
},
```

## Validators Pattern

### Always Validate User Input

```go
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
```

### Cross-Attribute Validation

```go
"id": schema.StringAttribute{
    Optional: true,
    Validators: []validator.String{
        stringvalidator.ExactlyOneOf(path.Expressions{
            path.MatchRoot("id"),
            path.MatchRoot("name"),
        }...),
    },
},

"name": schema.StringAttribute{
    Optional: true,
    Validators: []validator.String{
        stringvalidator.ExactlyOneOf(path.Expressions{
            path.MatchRoot("id"),
            path.MatchRoot("name"),
        }...),
    },
},
```

## Sensitive Attributes

Mark credentials and secrets:

```go
"api_key": schema.StringAttribute{
    Required:    true,
    Sensitive:   true,  // Masked in logs
    Description: "API authentication key",
},

"password": schema.StringAttribute{
    Required:    true,
    Sensitive:   true,
    Description: "User password",
},
```

## Documentation

### Always Provide Descriptions

```go
resp.Schema = schema.Schema{
    Description: "Manages a server instance",
    MarkdownDescription: "Manages a server instance.\n\n" +
        "Servers are virtual machines with configurable resources.",

    Attributes: map[string]schema.Attribute{
        "name": schema.StringAttribute{
            Required:    true,
            Description: "Server name",
            MarkdownDescription: "Server name. Must be unique within the account.",
        },
    },
}
```

- Use `Description` for CLI help
- Use `MarkdownDescription` for generated docs

## Schema Patterns

### Resource ID Pattern

```go
"id": schema.StringAttribute{
    Computed:    true,
    Description: "Unique identifier",
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Timestamp Pattern

```go
"created_at": schema.StringAttribute{
    Computed:    true,
    Description: "Creation timestamp",
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},

"updated_at": schema.StringAttribute{
    Computed:    true,
    Description: "Last update timestamp",
},
```

### Tags/Labels Pattern

```go
"tags": schema.MapAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Description: "Resource tags",
},
```

### Nested Configuration Pattern

```go
"network": schema.SingleNestedAttribute{
    Required:    true,
    Description: "Network configuration",
    Attributes: map[string]schema.Attribute{
        "vpc_id": schema.StringAttribute{
            Required:    true,
            Description: "VPC identifier",
        },
        "subnet_id": schema.StringAttribute{
            Required:    true,
            Description: "Subnet identifier",
        },
    },
},
```

### List of Objects Pattern

```go
"disks": schema.ListNestedAttribute{
    Optional:    true,
    Description: "Attached disks",
    NestedObject: schema.NestedAttributeObject{
        Attributes: map[string]schema.Attribute{
            "name": schema.StringAttribute{
                Required:    true,
                Description: "Disk name",
            },
            "size": schema.Int64Attribute{
                Required:    true,
                Description: "Disk size in GB",
                Validators: []validator.Int64{
                    int64validator.AtLeast(1),
                },
            },
        },
    },
},
```

## Deprecation

Mark deprecated attributes:

```go
"old_field": schema.StringAttribute{
    Optional:           true,
    DeprecationMessage: "Use new_field instead. old_field will be removed in v2.0.0",
},

"new_field": schema.StringAttribute{
    Optional: true,
},
```

## Anti-Patterns

### ❌ Don't: Omit descriptions

```go
// BAD: No description
"name": schema.StringAttribute{
    Required: true,
},
```

### ❌ Don't: Skip validators

```go
// BAD: No validation on user input
"port": schema.Int64Attribute{
    Required: true,
    // Missing: validators
},
```

### ❌ Don't: Forget sensitive marker

```go
// BAD: Credentials not marked sensitive
"password": schema.StringAttribute{
    Required: true,
    // Missing: Sensitive: true
},
```

### ❌ Don't: Mix Required and Computed

```go
// BAD: Invalid combination
"field": schema.StringAttribute{
    Required: true,
    Computed: true,  // Error: Can't combine Required + Computed
},
```

### ✅ Do: Complete schema design

```go
// GOOD: Complete with description, validators, modifiers
"name": schema.StringAttribute{
    Required:    true,
    Description: "Resource name (1-100 characters)",
    Validators: []validator.String{
        stringvalidator.LengthBetween(1, 100),
    },
},

"id": schema.StringAttribute{
    Computed:    true,
    Description: "Unique identifier",
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},

"api_key": schema.StringAttribute{
    Required:    true,
    Sensitive:   true,
    Description: "API authentication key",
},
```

## Schema Organization

Group related attributes:

```go
resp.Schema = schema.Schema{
    Description: "Manages a server",

    Attributes: map[string]schema.Attribute{
        // Identity
        "id":   /* ... */,
        "name": /* ... */,

        // Configuration
        "region": /* ... */,
        "size":   /* ... */,

        // Network
        "vpc_id":    /* ... */,
        "subnet_id": /* ... */,

        // Metadata
        "tags":       /* ... */,
        "created_at": /* ... */,
        "updated_at": /* ... */,
    },
}
```

## Summary

- ✅ **Always** provide descriptions for attributes
- ✅ **Always** use `UseStateForUnknown()` for IDs
- ✅ **Always** validate user input with validators
- ✅ **Always** mark credentials as sensitive
- ✅ Use `RequiresReplace()` for immutable attributes
- ❌ **Never** combine `Required` and `Computed`
- ❌ **Never** omit validators on user-provided values
- ❌ **Never** expose sensitive values without `Sensitive: true`
