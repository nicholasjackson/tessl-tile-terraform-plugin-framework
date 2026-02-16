# Type System

Understand framework types, conversions between Go and Terraform types, and null/unknown value handling.

## Overview

The framework uses a rich type system distinct from Go's primitive types. Framework types:
- Handle `null` and `unknown` values
- Provide semantic conversion to/from Go types
- Integrate with Terraform's type system
- Support custom type implementations

**Key principle:** Always use framework types (`types.String`, `types.Int64`, etc.) in resource models, not Go primitives.

## Framework Types

### Primitive Types

```go
import "github.com/hashicorp/terraform-plugin-framework/types"

type UserModel struct {
    ID          types.String  `tfsdk:"id"`
    Name        types.String  `tfsdk:"name"`
    Age         types.Int64   `tfsdk:"age"`
    Score       types.Float64 `tfsdk:"score"`
    Active      types.Bool    `tfsdk:"active"`
    Balance     types.Number  `tfsdk:"balance"`  // Arbitrary precision
}
```

### Collection Types

```go
type ServerModel struct {
    Tags        types.List    `tfsdk:"tags"`         // List of strings
    Roles       types.Set     `tfsdk:"roles"`        // Set of strings
    Labels      types.Map     `tfsdk:"labels"`       // Map of strings
    Config      types.Object  `tfsdk:"config"`       // Structured object
}
```

### Dynamic Type

For values with unknown structure:

```go
type ResourceModel struct {
    Configuration types.Dynamic `tfsdk:"configuration"`
}
```

## Value Conversions

### Framework to Go

```go
func (r *UserResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan UserModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Convert framework types to Go types
    id := plan.ID.ValueString()           // types.String → string
    name := plan.Name.ValueString()       // types.String → string
    age := plan.Age.ValueInt64()          // types.Int64 → int64
    score := plan.Score.ValueFloat64()    // types.Float64 → float64
    active := plan.Active.ValueBool()     // types.Bool → bool

    // Use Go values in API calls
    user, err := r.client.CreateUser(ctx, &CreateUserRequest{
        Name:   name,
        Age:    int(age),
        Active: active,
    })
    // ...
}
```

### Go to Framework

```go
func (r *UserResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // ... API call returns user ...

    // Convert Go types to framework types
    state := UserModel{
        ID:     types.StringValue(user.ID),           // string → types.String
        Name:   types.StringValue(user.Name),         // string → types.String
        Age:    types.Int64Value(int64(user.Age)),    // int64 → types.Int64
        Score:  types.Float64Value(user.Score),       // float64 → types.Float64
        Active: types.BoolValue(user.Active),         // bool → types.Bool
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

### Pointer Conversions

For optional Go values:

```go
// Go pointer to framework type
var description *string = getDescription()

if description != nil {
    model.Description = types.StringValue(*description)
} else {
    model.Description = types.StringNull()
}

// Framework type to Go pointer
descPtr := plan.Description.ValueStringPointer()  // *string
```

## Null and Unknown Values

### Null Values

`null` means explicitly no value (user set to `null` or omitted optional attribute):

```go
// Check if null
if plan.Description.IsNull() {
    // Field is null
}

// Set null value
model.Description = types.StringNull()

// Get value with null check
if !plan.Description.IsNull() {
    desc := plan.Description.ValueString()
    // Use desc
}
```

### Unknown Values

`unknown` means value not yet known (depends on another resource, computed during apply):

```go
// Check if unknown
if plan.ServerID.IsUnknown() {
    // Value computed during apply
    resp.Diagnostics.AddWarning(
        "Unknown Value",
        "Server ID is not yet known",
    )
    return
}

// Get value with unknown check
if !plan.ServerID.IsNull() && !plan.ServerID.IsUnknown() {
    serverID := plan.ServerID.ValueString()
    // Use serverID
}
```

### Safe Value Access Pattern

Always check null/unknown before accessing:

```go
// WRONG: May panic
name := plan.Name.ValueString()  // Panics if null or unknown

// RIGHT: Check first
if plan.Name.IsNull() {
    // Handle null
} else if plan.Name.IsUnknown() {
    // Handle unknown
} else {
    name := plan.Name.ValueString()
    // Use name
}

// OR: Use pointer (returns nil if null/unknown)
namePtr := plan.Name.ValueStringPointer()
if namePtr != nil {
    name := *namePtr
    // Use name
}
```

## Collection Type Conversions

### List Conversions

```go
// Framework list to Go slice
var tags types.List
tagElements := make([]types.String, 0, len(tags.Elements()))
resp.Diagnostics.Append(tags.ElementsAs(ctx, &tagElements, false)...)

goTags := make([]string, len(tagElements))
for i, tag := range tagElements {
    goTags[i] = tag.ValueString()
}

// Go slice to framework list
goTags := []string{"web", "api", "prod"}

tagValues := make([]attr.Value, len(goTags))
for i, tag := range goTags {
    tagValues[i] = types.StringValue(tag)
}

tagsList, diags := types.ListValue(types.StringType, tagValues)
resp.Diagnostics.Append(diags...)
if resp.Diagnostics.HasError() {
    return
}

model.Tags = tagsList
```

### Set Conversions

```go
// Framework set to Go slice
var roles types.Set
roleElements := make([]types.String, 0, len(roles.Elements()))
resp.Diagnostics.Append(roles.ElementsAs(ctx, &roleElements, false)...)

goRoles := make([]string, len(roleElements))
for i, role := range roleElements {
    goRoles[i] = role.ValueString()
}

// Go slice to framework set
goRoles := []string{"admin", "editor", "viewer"}

roleValues := make([]attr.Value, len(goRoles))
for i, role := range goRoles {
    roleValues[i] = types.StringValue(role)
}

rolesSet, diags := types.SetValue(types.StringType, roleValues)
resp.Diagnostics.Append(diags...)
model.Roles = rolesSet
```

### Map Conversions

```go
// Framework map to Go map
var labels types.Map
labelElements := make(map[string]types.String)
resp.Diagnostics.Append(labels.ElementsAs(ctx, &labelElements, false)...)

goLabels := make(map[string]string, len(labelElements))
for k, v := range labelElements {
    goLabels[k] = v.ValueString()
}

// Go map to framework map
goLabels := map[string]string{
    "env":  "prod",
    "team": "platform",
}

labelValues := make(map[string]attr.Value, len(goLabels))
for k, v := range goLabels {
    labelValues[k] = types.StringValue(v)
}

labelsMap, diags := types.MapValue(types.StringType, labelValues)
resp.Diagnostics.Append(diags...)
model.Labels = labelsMap
```

### Object Conversions

```go
// Define object type
type AddressModel struct {
    Street  types.String `tfsdk:"street"`
    City    types.String `tfsdk:"city"`
    Zipcode types.String `tfsdk:"zipcode"`
}

// Framework object to Go struct
var address types.Object
var addressData AddressModel
resp.Diagnostics.Append(address.As(ctx, &addressData, basetypes.ObjectAsOptions{})...)

street := addressData.Street.ValueString()
city := addressData.City.ValueString()

// Go struct to framework object
addressData := AddressModel{
    Street:  types.StringValue("123 Main St"),
    City:    types.StringValue("Portland"),
    Zipcode: types.StringValue("97201"),
}

addressObj, diags := types.ObjectValueFrom(ctx, addressData.AttributeTypes(), addressData)
resp.Diagnostics.Append(diags...)
model.Address = addressObj
```

## Dynamic Type Handling

Dynamic types can hold any framework type:

```go
// Read dynamic value
var config types.Dynamic

// Check what type it contains
if config.IsNull() {
    // No value
}

if config.IsUnderlyingValueString() {
    strVal := config.UnderlyingValue().(types.String)
    value := strVal.ValueString()
}

if config.IsUnderlyingValueObject() {
    objVal := config.UnderlyingValue().(types.Object)
    // Process object
}

// Set dynamic value
model.Config = types.DynamicValue(types.StringValue("example"))
model.Config = types.DynamicValue(types.Int64Value(42))
model.Config = types.DynamicValue(listValue)
```

## Custom Types

Define custom types with additional behavior:

```go
import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/attr"
    "github.com/hashicorp/terraform-plugin-framework/types/basetypes"
)

// Custom email type
type EmailType struct {
    basetypes.StringType
}

func (t EmailType) String() string {
    return "EmailType"
}

func (t EmailType) ValueFromString(ctx context.Context, in basetypes.StringValue) (basetypes.StringValuable, diag.Diagnostics) {
    var diags diag.Diagnostics

    // Validate email format
    email := in.ValueString()
    if !strings.Contains(email, "@") {
        diags.AddError(
            "Invalid Email",
            "Email must contain @ symbol",
        )
        return nil, diags
    }

    return EmailValue{
        StringValue: in,
    }, diags
}

type EmailValue struct {
    basetypes.StringValue
}

func (v EmailValue) Type(ctx context.Context) attr.Type {
    return EmailType{}
}

// Use in schema
"email": schema.StringAttribute{
    Required:   true,
    CustomType: EmailType{},
},
```

## Type Equality

Compare framework types:

```go
// Check equality
if plan.Name.Equal(state.Name) {
    // Values are equal
}

// For complex types
if plan.Tags.Equal(state.Tags) {
    // Lists are equal
}

// Null equality
if plan.Description.IsNull() && state.Description.IsNull() {
    // Both null
}
```

## Common Patterns

### Optional String with Default

```go
// Read with default
timeout := 30
if !plan.Timeout.IsNull() {
    timeout = int(plan.Timeout.ValueInt64())
}

// Set optional value
if timeout != 0 {
    model.Timeout = types.Int64Value(int64(timeout))
} else {
    model.Timeout = types.Int64Null()
}
```

### Nullable Pointer Fields

```go
// API returns pointer
type User struct {
    Name        string
    Description *string  // Nullable
}

user, err := r.client.GetUser(ctx, id)

// Map to framework type
if user.Description != nil {
    model.Description = types.StringValue(*user.Description)
} else {
    model.Description = types.StringNull()
}
```

### List of Objects

```go
type ServerModel struct {
    Disks []DiskModel `tfsdk:"disks"`
}

type DiskModel struct {
    Name types.String `tfsdk:"name"`
    Size types.Int64  `tfsdk:"size"`
}

// Convert API response
disks := make([]DiskModel, len(apiDisks))
for i, apiDisk := range apiDisks {
    disks[i] = DiskModel{
        Name: types.StringValue(apiDisk.Name),
        Size: types.Int64Value(int64(apiDisk.Size)),
    }
}

model.Disks = disks
```

### Computed List from State

```go
// Keep existing list if not changed
if plan.Tags.IsNull() && !state.Tags.IsNull() {
    // User removed tags, use null
    model.Tags = types.ListNull(types.StringType)
} else if plan.Tags.IsNull() && state.Tags.IsNull() {
    // Tags never set, use null
    model.Tags = types.ListNull(types.StringType)
} else if plan.Tags.IsUnknown() {
    // Use state value during plan
    model.Tags = state.Tags
} else {
    // Use plan value
    model.Tags = plan.Tags
}
```

## Error Handling

### Diagnostics with Type Conversions

```go
tagsList, diags := types.ListValue(types.StringType, tagValues)
resp.Diagnostics.Append(diags...)
if resp.Diagnostics.HasError() {
    return  // Always check after conversions
}

model.Tags = tagsList
```

### Attribute Path Errors

```go
resp.Diagnostics.AddAttributeError(
    path.Root("name"),
    "Invalid Name",
    "Name cannot be empty",
)

resp.Diagnostics.AddAttributeError(
    path.Root("disks").AtListIndex(0).AtName("size"),
    "Invalid Disk Size",
    "Size must be positive",
)
```

## Type Assertions

For dynamic or interface{} values:

```go
// Framework type assertion
value, ok := someValue.(types.String)
if !ok {
    resp.Diagnostics.AddError(
        "Type Assertion Failed",
        fmt.Sprintf("Expected types.String, got %T", someValue),
    )
    return
}

// Underlying value access
underlyingValue := dynamicValue.UnderlyingValue()
switch v := underlyingValue.(type) {
case types.String:
    str := v.ValueString()
case types.Int64:
    num := v.ValueInt64()
default:
    // Handle unknown type
}
```

## Testing with Framework Types

```go
func TestResourceCreate(t *testing.T) {
    model := UserModel{
        Name:   types.StringValue("Alice"),
        Age:    types.Int64Value(30),
        Active: types.BoolValue(true),
    }

    require.Equal(t, "Alice", model.Name.ValueString())
    require.Equal(t, int64(30), model.Age.ValueInt64())
    require.True(t, model.Active.ValueBool())
}

func TestNullHandling(t *testing.T) {
    model := UserModel{
        Name:        types.StringValue("Bob"),
        Description: types.StringNull(),
    }

    require.False(t, model.Name.IsNull())
    require.True(t, model.Description.IsNull())
}
```

## External References

- [Types Package](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/types)
- [Type System Guide](https://developer.hashicorp.com/terraform/plugin/framework/types)
- [Custom Types](https://developer.hashicorp.com/terraform/plugin/framework/custom-types)

## Navigation

- **Previous**: [Schema System](schema.md) - Schema design patterns
- **Next**: [Validators](validators.md) - Built-in and custom validators
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Validators](validators.md) to learn about validating attribute values with built-in and custom validators.*
