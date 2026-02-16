# Validators

Validate attribute values using built-in validators and create custom validators for domain-specific validation.

## Overview

Validators check attribute values during Terraform plan and apply operations. They:
- Run during plan phase (before API calls)
- Add errors or warnings to diagnostics
- Can validate single attributes or cross-attribute logic
- Are composable (multiple validators per attribute)

## Built-in Validators

The framework provides validators for common patterns via separate packages.

### String Validators

```go
import stringvalidator "github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"

"name": schema.StringAttribute{
    Required: true,
    Validators: []validator.String{
        // Length constraints
        stringvalidator.LengthAtLeast(1),
        stringvalidator.LengthAtMost(100),
        stringvalidator.LengthBetween(1, 100),

        // Value constraints
        stringvalidator.OneOf("small", "medium", "large"),
        stringvalidator.NoneOf("invalid", "forbidden"),

        // Pattern matching
        stringvalidator.RegexMatches(
            regexp.MustCompile(`^[a-z0-9-]+$`),
            "must contain only lowercase letters, numbers, and hyphens",
        ),

        // Conflicts
        stringvalidator.ConflictsWith(path.Expressions{
            path.MatchRoot("other_field"),
        }...),

        // At least one of
        stringvalidator.AtLeastOneOf(path.Expressions{
            path.MatchRoot("field_a"),
            path.MatchRoot("field_b"),
        }...),

        // Exactly one of
        stringvalidator.ExactlyOneOf(path.Expressions{
            path.MatchRoot("id"),
            path.MatchRoot("name"),
        }...),
    },
},
```

### Int64 Validators

```go
import int64validator "github.com/hashicorp/terraform-plugin-framework-validators/int64validator"

"port": schema.Int64Attribute{
    Required: true,
    Validators: []validator.Int64{
        // Range constraints
        int64validator.Between(1, 65535),
        int64validator.AtLeast(1),
        int64validator.AtMost(65535),

        // Value constraints
        int64validator.OneOf(80, 443, 8080),
        int64validator.NoneOf(22, 23),

        // Conflicts
        int64validator.ConflictsWith(path.Expressions{
            path.MatchRoot("other_port"),
        }...),
    },
},
```

### Float64 Validators

```go
import float64validator "github.com/hashicorp/terraform-plugin-framework-validators/float64validator"

"threshold": schema.Float64Attribute{
    Required: true,
    Validators: []validator.Float64{
        float64validator.Between(0.0, 1.0),
        float64validator.AtLeast(0.0),
        float64validator.AtMost(1.0),
    },
},
```

### Bool Validators

```go
import boolvalidator "github.com/hashicorp/terraform-plugin-framework-validators/boolvalidator"

"enabled": schema.BoolAttribute{
    Optional: true,
    Validators: []validator.Bool{
        boolvalidator.AlsoRequires(path.Expressions{
            path.MatchRoot("config"),
        }...),
    },
},
```

### List Validators

```go
import listvalidator "github.com/hashicorp/terraform-plugin-framework-validators/listvalidator"

"tags": schema.ListAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Validators: []validator.List{
        // Size constraints
        listvalidator.SizeAtLeast(1),
        listvalidator.SizeAtMost(10),
        listvalidator.SizeBetween(1, 10),

        // Element validators
        listvalidator.ValueStringsAre(
            stringvalidator.LengthAtLeast(1),
        ),

        // Uniqueness
        listvalidator.UniqueValues(),
    },
},
```

### Set Validators

```go
import setvalidator "github.com/hashicorp/terraform-plugin-framework-validators/setvalidator"

"roles": schema.SetAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Validators: []validator.Set{
        setvalidator.SizeAtLeast(1),
        setvalidator.SizeAtMost(5),
        setvalidator.ValueStringsAre(
            stringvalidator.OneOf("admin", "editor", "viewer"),
        ),
    },
},
```

### Map Validators

```go
import mapvalidator "github.com/hashicorp/terraform-plugin-framework-validators/mapvalidator"

"labels": schema.MapAttribute{
    ElementType: types.StringType,
    Optional:    true,
    Validators: []validator.Map{
        mapvalidator.SizeAtLeast(1),
        mapvalidator.SizeAtMost(20),
        mapvalidator.KeysAre(
            stringvalidator.LengthBetween(1, 50),
        ),
        mapvalidator.ValuesAre(
            stringvalidator.LengthBetween(1, 200),
        ),
    },
},
```

### Object Validators

```go
import objectvalidator "github.com/hashicorp/terraform-plugin-framework-validators/objectvalidator"

"config": schema.SingleNestedAttribute{
    Optional: true,
    Attributes: map[string]schema.Attribute{
        "host": schema.StringAttribute{Required: true},
        "port": schema.Int64Attribute{Required: true},
    },
    Validators: []validator.Object{
        objectvalidator.AlsoRequires(path.Expressions{
            path.MatchRoot("credentials"),
        }...),
    },
},
```

## Cross-Attribute Validation

Validate relationships between multiple attributes:

```go
"id": schema.StringAttribute{
    Optional: true,
    Validators: []validator.String{
        // Exactly one of id or name must be set
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

"ssl_enabled": schema.BoolAttribute{
    Optional: true,
    Validators: []validator.Bool{
        // ssl_enabled requires ssl_certificate
        boolvalidator.AlsoRequires(path.Expressions{
            path.MatchRoot("ssl_certificate"),
        }...),
    },
},

"http_port": schema.Int64Attribute{
    Optional: true,
    Validators: []validator.Int64{
        // http_port conflicts with https_port
        int64validator.ConflictsWith(path.Expressions{
            path.MatchRoot("https_port"),
        }...),
    },
},
```

## Custom Validators

Create custom validators for domain-specific validation.

### String Validator Example

```go
package validators

import (
    "context"
    "fmt"
    "strings"

    "github.com/hashicorp/terraform-plugin-framework/schema/validator"
)

var _ validator.String = (*emailValidator)(nil)

type emailValidator struct{}

func Email() validator.String {
    return emailValidator{}
}

func (v emailValidator) Description(ctx context.Context) string {
    return "value must be a valid email address"
}

func (v emailValidator) MarkdownDescription(ctx context.Context) string {
    return "value must be a valid email address"
}

func (v emailValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    // Skip validation if value is null or unknown
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueString()

    // Basic email validation
    if !strings.Contains(value, "@") || !strings.Contains(value, ".") {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Email Address",
            fmt.Sprintf("'%s' is not a valid email address", value),
        )
        return
    }

    parts := strings.Split(value, "@")
    if len(parts) != 2 || len(parts[0]) == 0 || len(parts[1]) == 0 {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Email Address",
            fmt.Sprintf("'%s' is not a valid email address", value),
        )
    }
}

// Use in schema
"email": schema.StringAttribute{
    Required: true,
    Validators: []validator.String{
        validators.Email(),
    },
},
```

### Int64 Validator Example

```go
var _ validator.Int64 = (*portValidator)(nil)

type portValidator struct{}

func ValidPort() validator.Int64 {
    return portValidator{}
}

func (v portValidator) Description(ctx context.Context) string {
    return "value must be a valid port number (1-65535)"
}

func (v portValidator) MarkdownDescription(ctx context.Context) string {
    return "value must be a valid port number (1-65535)"
}

func (v portValidator) ValidateInt64(ctx context.Context, req validator.Int64Request, resp *validator.Int64Response) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueInt64()

    if value < 1 || value > 65535 {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Port",
            fmt.Sprintf("Port must be between 1 and 65535, got: %d", value),
        )
    }

    // Warn about privileged ports
    if value < 1024 {
        resp.Diagnostics.AddAttributeWarning(
            req.Path,
            "Privileged Port",
            fmt.Sprintf("Port %d is a privileged port (< 1024) and may require elevated permissions", value),
        )
    }
}
```

### Object Validator Example

```go
var _ validator.Object = (*configValidator)(nil)

type configValidator struct{}

func ValidConfig() validator.Object {
    return configValidator{}
}

func (v configValidator) Description(ctx context.Context) string {
    return "validates configuration object"
}

func (v configValidator) MarkdownDescription(ctx context.Context) string {
    return "validates configuration object"
}

func (v configValidator) ValidateObject(ctx context.Context, req validator.ObjectRequest, resp *validator.ObjectResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    // Extract object attributes
    attrs := req.ConfigValue.Attributes()

    host, ok := attrs["host"].(types.String)
    if !ok {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Config",
            "host attribute is required",
        )
        return
    }

    port, ok := attrs["port"].(types.Int64)
    if !ok {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Config",
            "port attribute is required",
        )
        return
    }

    // Validate combination
    if host.ValueString() == "localhost" && port.ValueInt64() != 8080 {
        resp.Diagnostics.AddAttributeWarning(
            req.Path,
            "Non-Standard Configuration",
            "localhost typically uses port 8080",
        )
    }
}
```

## Validator Patterns

### Parameterized Validator

```go
type lengthBetweenValidator struct {
    min int
    max int
}

func LengthBetween(min, max int) validator.String {
    return lengthBetweenValidator{
        min: min,
        max: max,
    }
}

func (v lengthBetweenValidator) Description(ctx context.Context) string {
    return fmt.Sprintf("value length must be between %d and %d", v.min, v.max)
}

func (v lengthBetweenValidator) MarkdownDescription(ctx context.Context) string {
    return fmt.Sprintf("value length must be between %d and %d", v.min, v.max)
}

func (v lengthBetweenValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueString()
    length := len(value)

    if length < v.min || length > v.max {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Length",
            fmt.Sprintf("Length must be between %d and %d, got: %d", v.min, v.max, length),
        )
    }
}

// Use
"name": schema.StringAttribute{
    Required: true,
    Validators: []validator.String{
        LengthBetween(1, 100),
    },
},
```

### Conditional Validator

```go
func (v emailValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    // Get related attribute
    var contactType types.String
    resp.Diagnostics.Append(req.Config.GetAttribute(ctx, path.Root("contact_type"), &contactType)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Only validate if contact_type is "email"
    if contactType.ValueString() != "email" {
        return
    }

    value := req.ConfigValue.ValueString()
    if !strings.Contains(value, "@") {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid Email",
            "Email address must contain @",
        )
    }
}
```

### Warning vs Error

```go
func (v validator) Validate(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    value := req.ConfigValue.ValueString()

    // Error: Blocks plan/apply
    if value == "" {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Empty Value",
            "Value cannot be empty",
        )
        return
    }

    // Warning: Continues plan/apply
    if value == "default" {
        resp.Diagnostics.AddAttributeWarning(
            req.Path,
            "Default Value",
            "Using default value may not be optimal for production",
        )
    }
}
```

## Testing Validators

```go
func TestEmailValidator(t *testing.T) {
    validator := Email()

    tests := []struct {
        name        string
        value       types.String
        expectError bool
    }{
        {
            name:        "valid email",
            value:       types.StringValue("user@example.com"),
            expectError: false,
        },
        {
            name:        "invalid - no @",
            value:       types.StringValue("userexample.com"),
            expectError: true,
        },
        {
            name:        "invalid - no domain",
            value:       types.StringValue("user@"),
            expectError: true,
        },
        {
            name:        "null value",
            value:       types.StringNull(),
            expectError: false,  // Validators skip null
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            req := validator.StringRequest{
                ConfigValue: tt.value,
                Path:        path.Root("email"),
            }
            resp := &validator.StringResponse{}

            validator.ValidateString(context.Background(), req, resp)

            if tt.expectError {
                require.True(t, resp.Diagnostics.HasError(), "expected error but got none")
            } else {
                require.False(t, resp.Diagnostics.HasError(), "expected no error but got: %v", resp.Diagnostics)
            }
        })
    }
}
```

## Common Validation Patterns

### Enum Validation

```go
"size": schema.StringAttribute{
    Required: true,
    Validators: []validator.String{
        stringvalidator.OneOf("small", "medium", "large", "xlarge"),
    },
},
```

### CIDR Validation

```go
func ValidCIDR() validator.String {
    return &cidrValidator{}
}

func (v cidrValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueString()
    _, _, err := net.ParseCIDR(value)
    if err != nil {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid CIDR",
            fmt.Sprintf("'%s' is not a valid CIDR: %s", value, err.Error()),
        )
    }
}
```

### URL Validation

```go
func ValidURL() validator.String {
    return &urlValidator{}
}

func (v urlValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueString()
    parsedURL, err := url.Parse(value)
    if err != nil || parsedURL.Scheme == "" || parsedURL.Host == "" {
        resp.Diagnostics.AddAttributeError(
            req.Path,
            "Invalid URL",
            fmt.Sprintf("'%s' is not a valid URL", value),
        )
    }
}
```

## External References

- [Validator Packages](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework-validators)
- [Custom Validators Guide](https://developer.hashicorp.com/terraform/plugin/framework/validation#custom-validators)
- [Built-in Validators](https://developer.hashicorp.com/terraform/plugin/framework/validation)

## Navigation

- **Previous**: [Type System](types.md) - Framework types and conversions
- **Next**: [Plan Modifiers](plan-modifiers.md) - Plan modification patterns
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Plan Modifiers](plan-modifiers.md) to learn about controlling plan behavior with UseStateForUnknown and RequiresReplace.*
