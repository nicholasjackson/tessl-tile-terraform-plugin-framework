# Plan Modifiers

Control Terraform plan behavior with built-in and custom plan modifiers.

## Overview

Plan modifiers alter the planned value for an attribute during the planning phase. They:
- Run during `terraform plan` to modify planned values
- Control whether changes trigger resource replacement
- Prevent unnecessary "known after apply" values
- Can use state values to inform plan values

**Critical pattern:** Use `UseStateForUnknown()` for computed attributes to prevent unnecessary resource replacements.

## Built-in Plan Modifiers

### String Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"

"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        // Use state value if plan value is unknown
        stringplanmodifier.UseStateForUnknown(),
    },
},

"region": schema.StringAttribute{
    Required: true,
    PlanModifiers: []planmodifier.String{
        // Require resource replacement if value changes
        stringplanmodifier.RequiresReplace(),
    },
},

"name": schema.StringAttribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.String{
        // Only if null, use default value
        stringplanmodifier.RequiresReplaceIfConfigured(),
    },
},
```

### Int64 Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/int64planmodifier"

"port": schema.Int64Attribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.Int64{
        int64planmodifier.UseStateForUnknown(),
        int64planmodifier.RequiresReplace(),
    },
},
```

### Bool Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/boolplanmodifier"

"enabled": schema.BoolAttribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.Bool{
        boolplanmodifier.UseStateForUnknown(),
    },
},
```

### Float64 Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/float64planmodifier"

"threshold": schema.Float64Attribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.Float64{
        float64planmodifier.UseStateForUnknown(),
    },
},
```

### List/Set/Map Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/listplanmodifier"
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/setplanmodifier"
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/mapplanmodifier"

"tags": schema.ListAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Computed:    true,
    PlanModifiers: []planmodifier.List{
        listplanmodifier.UseStateForUnknown(),
    },
},

"roles": schema.SetAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Computed:    true,
    PlanModifiers: []planmodifier.Set{
        setplanmodifier.UseStateForUnknown(),
    },
},

"labels": schema.MapAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Computed:    true,
    PlanModifiers: []planmodifier.Map{
        mapplanmodifier.UseStateForUnknown(),
    },
},
```

### Object Plan Modifiers

```go
import "github.com/hashicorp/terraform-plugin-framework/resource/schema/objectplanmodifier"

"config": schema.SingleNestedAttribute{
    Optional: true,
    Computed: true,
    Attributes: map[string]schema.Attribute{
        "host": schema.StringAttribute{Required: true},
        "port": schema.Int64Attribute{Required: true},
    },
    PlanModifiers: []planmodifier.Object{
        objectplanmodifier.UseStateForUnknown(),
    },
},
```

## UseStateForUnknown Pattern

**Most important plan modifier** - prevents "known after apply" when value doesn't actually change.

### Without UseStateForUnknown

```go
"id": schema.StringAttribute{
    Computed: true,
    // NO plan modifier
},
```

**Result:**
```
# terraform plan
  ~ resource "example_pet" "fluffy" {
      ~ id      = "pet-123" -> (known after apply)  # Unnecessary!
        name    = "Fluffy"
    }
```

### With UseStateForUnknown

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

**Result:**
```
# terraform plan
resource "example_pet" "fluffy" {
    id   = "pet-123"  # Stays as is
    name = "Fluffy"
}
```

### When to Use

Use `UseStateForUnknown()` for:
- **IDs** - Computed identifiers that don't change
- **Computed timestamps** - Created/updated times that don't change on every apply
- **Computed attributes from API** - Values computed by API that are stable

Don't use for:
- **Truly dynamic values** - Values that change on every apply (e.g., current timestamp)
- **Values that depend on other changes** - Computed values that recalculate when inputs change

## RequiresReplace Pattern

Force resource replacement when attribute changes.

### Basic Usage

```go
"region": schema.StringAttribute{
    Required: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),
    },
},
```

**Result:**
```
# terraform plan
  # example_server.web must be replaced
-/+ resource "example_server" "web" {
      ~ region = "us-west-1" -> "us-east-1" # forces replacement
    }
```

### When to Use

Use `RequiresReplace()` for immutable attributes:
- **Region/Zone** - Cannot be changed after creation
- **Image ID** - Changing requires new instance
- **Disk type** - Cannot be changed for existing disk
- **Network configuration** - Immutable network settings

### RequiresReplaceIf

Conditional replacement:

```go
"size": schema.StringAttribute{
    Optional: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplaceIf(
            func(ctx context.Context, req planmodifier.StringRequest, resp *stringplanmodifier.RequiresReplaceIfFuncResponse) {
                // Only require replacement if downgrading
                if req.StateValue.IsNull() {
                    return
                }

                oldSize := req.StateValue.ValueString()
                newSize := req.PlanValue.ValueString()

                sizeOrder := map[string]int{
                    "small":  1,
                    "medium": 2,
                    "large":  3,
                }

                if sizeOrder[newSize] < sizeOrder[oldSize] {
                    resp.RequiresReplace = true
                }
            },
            "Downgrading size requires replacement",
            "Downgrading size requires replacement",
        ),
    },
},
```

### RequiresReplaceIfConfigured

Only replace if user explicitly sets value:

```go
"override": schema.StringAttribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplaceIfConfigured(),
    },
},
```

## Custom Plan Modifiers

Create custom plan modifiers for domain-specific logic.

### String Plan Modifier Example

```go
package planmodifiers

import (
    "context"

    "github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
)

var _ planmodifier.String = (*defaultValueModifier)(nil)

type defaultValueModifier struct {
    defaultValue string
}

func DefaultValue(defaultValue string) planmodifier.String {
    return &defaultValueModifier{
        defaultValue: defaultValue,
    }
}

func (m *defaultValueModifier) Description(ctx context.Context) string {
    return "Sets a default value if not configured"
}

func (m *defaultValueModifier) MarkdownDescription(ctx context.Context) string {
    return "Sets a default value if not configured"
}

func (m *defaultValueModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    // If value is null in config, set default
    if req.ConfigValue.IsNull() {
        resp.PlanValue = types.StringValue(m.defaultValue)
    }
}

// Use in schema
"environment": schema.StringAttribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.String{
        planmodifiers.DefaultValue("production"),
    },
},
```

### Timestamp Plan Modifier Example

```go
var _ planmodifier.String = (*immutableTimestampModifier)(nil)

type immutableTimestampModifier struct{}

func ImmutableTimestamp() planmodifier.String {
    return &immutableTimestampModifier{}
}

func (m *immutableTimestampModifier) Description(ctx context.Context) string {
    return "Ensures timestamp is only set once and never changes"
}

func (m *immutableTimestampModifier) MarkdownDescription(ctx context.Context) string {
    return "Ensures timestamp is only set once and never changes"
}

func (m *immutableTimestampModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    // If state has a value, always use it
    if !req.StateValue.IsNull() {
        resp.PlanValue = req.StateValue
        return
    }

    // If no state value (creation), set current time
    if req.PlanValue.IsUnknown() {
        resp.PlanValue = types.StringValue(time.Now().UTC().Format(time.RFC3339))
    }
}

// Use in schema
"created_at": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        planmodifiers.ImmutableTimestamp(),
    },
},
```

### Conditional Replace Plan Modifier

```go
var _ planmodifier.String = (*conditionalReplaceModifier)(nil)

type conditionalReplaceModifier struct {
    attributePath path.Path
}

func RequiresReplaceIfAttributeSet(attributePath path.Path) planmodifier.String {
    return &conditionalReplaceModifier{
        attributePath: attributePath,
    }
}

func (m *conditionalReplaceModifier) Description(ctx context.Context) string {
    return "Requires replacement if specified attribute is set"
}

func (m *conditionalReplaceModifier) MarkdownDescription(ctx context.Context) string {
    return "Requires replacement if specified attribute is set"
}

func (m *conditionalReplaceModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    // Check if values changed
    if req.StateValue.Equal(req.PlanValue) {
        return
    }

    // Get the conditional attribute
    var attrValue types.Bool
    resp.Diagnostics.Append(req.Plan.GetAttribute(ctx, m.attributePath, &attrValue)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Require replacement if attribute is true
    if !attrValue.IsNull() && attrValue.ValueBool() {
        resp.RequiresReplace = true
    }
}
```

## Plan Modifier Patterns

### Incrementing Version

```go
var _ planmodifier.Int64 = (*incrementVersionModifier)(nil)

type incrementVersionModifier struct{}

func IncrementVersion() planmodifier.Int64 {
    return &incrementVersionModifier{}
}

func (m *incrementVersionModifier) PlanModifyInt64(ctx context.Context, req planmodifier.Int64Request, resp *planmodifier.Int64Response) {
    // If state exists, increment version
    if !req.StateValue.IsNull() {
        currentVersion := req.StateValue.ValueInt64()
        resp.PlanValue = types.Int64Value(currentVersion + 1)
    } else {
        // First version is 1
        resp.PlanValue = types.Int64Value(1)
    }
}
```

### Normalize Case

```go
func (m *lowercaseModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    if req.PlanValue.IsNull() || req.PlanValue.IsUnknown() {
        return
    }

    value := req.PlanValue.ValueString()
    resp.PlanValue = types.StringValue(strings.ToLower(value))
}
```

### Generate Random ID

```go
func (m *generateIDModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    // If state exists, keep it
    if !req.StateValue.IsNull() {
        resp.PlanValue = req.StateValue
        return
    }

    // Generate new ID on creation
    if req.PlanValue.IsUnknown() {
        id := fmt.Sprintf("id-%d", time.Now().UnixNano())
        resp.PlanValue = types.StringValue(id)
    }
}
```

## Testing Plan Modifiers

```go
func TestDefaultValueModifier(t *testing.T) {
    modifier := DefaultValue("default")

    req := planmodifier.StringRequest{
        ConfigValue: types.StringNull(),  // Not set in config
        PlanValue:   types.StringUnknown(),
    }
    resp := &planmodifier.StringResponse{
        PlanValue: req.PlanValue,
    }

    modifier.PlanModifyString(context.Background(), req, resp)

    require.Equal(t, "default", resp.PlanValue.ValueString())
}

func TestImmutableTimestampModifier(t *testing.T) {
    modifier := ImmutableTimestamp()

    // Test with existing state
    stateTime := "2025-01-01T00:00:00Z"
    req := planmodifier.StringRequest{
        StateValue: types.StringValue(stateTime),
        PlanValue:  types.StringUnknown(),
    }
    resp := &planmodifier.StringResponse{
        PlanValue: req.PlanValue,
    }

    modifier.PlanModifyString(context.Background(), req, resp)

    // Should preserve state value
    require.Equal(t, stateTime, resp.PlanValue.ValueString())
}
```

## Common Patterns

### Computed ID Pattern

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Immutable Attribute Pattern

```go
"immutable_field": schema.StringAttribute{
    Required: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),
    },
},
```

### Optional with Computed Default Pattern

```go
"status": schema.StringAttribute{
    Optional: true,
    Computed: true,
    PlanModifiers: []planmodifier.String{
        planmodifiers.DefaultValue("active"),
    },
},
```

### Timestamp Pattern

```go
"created_at": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        planmodifiers.ImmutableTimestamp(),
    },
},

"updated_at": schema.StringAttribute{
    Computed: true,
    // No modifier - always update
},
```

## External References

- [Plan Modifier Packages](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier)
- [Custom Plan Modifiers](https://developer.hashicorp.com/terraform/plugin/framework/resources/plan-modification)
- [UseStateForUnknown Documentation](https://developer.hashicorp.com/terraform/plugin/framework/resources/plan-modification#usestateforunknown)

## Navigation

- **Previous**: [Validators](validators.md) - Built-in and custom validators
- **Next**: [Functions](functions.md) - Provider functions
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Functions](functions.md) to learn about implementing provider-defined Terraform functions.*
