# Common Pitfalls

Consolidated list of common mistakes and gotchas when using terraform-plugin-framework.

## Critical Pitfalls

### 1. Not Checking Diagnostics

**Problem:** Continuing execution after diagnostic errors leads to panics.

```go
// ❌ WRONG: Missing diagnostic check
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
// Missing: if resp.Diagnostics.HasError() { return }
name := plan.Name.ValueString()  // PANIC if Get() failed!

// ✅ CORRECT: Always check diagnostics
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
if resp.Diagnostics.HasError() {
    return
}
name := plan.Name.ValueString()  // Safe
```

### 2. Missing UseStateForUnknown on IDs

**Problem:** IDs show as "known after apply" unnecessarily, causing confusion and unnecessary replaces.

```go
// ❌ WRONG: Missing plan modifier
"id": schema.StringAttribute{
    Computed: true,
    // Missing: PlanModifiers
},

// ✅ CORRECT: Use UseStateForUnknown
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### 3. Type Conversion Without Null/Unknown Checks

**Problem:** Accessing values without checking null/unknown causes panics.

```go
// ❌ WRONG: No null check
name := plan.Name.ValueString()  // Panics if null/unknown

// ✅ CORRECT: Check before accessing
if plan.Name.IsNull() || plan.Name.IsUnknown() {
    // Handle null/unknown case
} else {
    name := plan.Name.ValueString()
    // Use name safely
}

// OR: Use pointer (returns nil if null/unknown)
namePtr := plan.Name.ValueStringPointer()
if namePtr != nil {
    name := *namePtr
    // Use name
}
```

### 4. Forgetting resp.State.Set() in CRUD

**Problem:** State not saved, Terraform thinks resource doesn't exist.

```go
// ❌ WRONG: Missing State.Set
func (r *Resource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan ResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)

    // Create via API...
    // Missing: resp.State.Set(ctx, &state)
}

// ✅ CORRECT: Always set state
func (r *Resource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan ResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Create via API...
    state := ResourceModel{ /* ... */ }
    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

### 5. Calling State.Set() in Delete

**Problem:** State should be automatically removed, don't set it in Delete.

```go
// ❌ WRONG: Setting state in Delete
func (r *Resource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    // Delete via API...
    resp.State.Set(ctx, &emptyState)  // Don't do this
}

// ✅ CORRECT: Don't set state in Delete
func (r *Resource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    // Delete via API...
    // State automatically removed
}
```

## Schema Pitfalls

### 6. Combining Required and Computed

**Problem:** Invalid schema constraint combination.

```go
// ❌ WRONG: Can't combine Required and Computed
"field": schema.StringAttribute{
    Required: true,
    Computed: true,  // Error!
},

// ✅ CORRECT: Use Optional + Computed for user-or-provider values
"field": schema.StringAttribute{
    Optional: true,
    Computed: true,
},
```

### 7. Missing Validators on User Input

**Problem:** No validation allows invalid data, API errors occur later.

```go
// ❌ WRONG: No validation
"port": schema.Int64Attribute{
    Required: true,
    // Missing: validators
},

// ✅ CORRECT: Always validate user input
"port": schema.Int64Attribute{
    Required: true,
    Validators: []validator.Int64{
        int64validator.Between(1, 65535),
    },
},
```

### 8. Not Marking Sensitive Attributes

**Problem:** Credentials exposed in logs and state files.

```go
// ❌ WRONG: Credentials not marked sensitive
"password": schema.StringAttribute{
    Required: true,
    // Missing: Sensitive: true
},

// ✅ CORRECT: Mark credentials as sensitive
"password": schema.StringAttribute{
    Required: true,
    Sensitive: true,
},
```

### 9. Missing Descriptions

**Problem:** No documentation generated for provider.

```go
// ❌ WRONG: No description
"name": schema.StringAttribute{
    Required: true,
},

// ✅ CORRECT: Always add descriptions
"name": schema.StringAttribute{
    Required:    true,
    Description: "Resource name (1-100 characters)",
},
```

## Type System Pitfalls

### 10. Using Go Primitives Instead of Framework Types

**Problem:** Cannot represent null/unknown, breaks Terraform semantics.

```go
// ❌ WRONG: Go primitives
type ResourceModel struct {
    Name string  // Can't represent null/unknown
    Age  int64   // Can't represent null/unknown
}

// ✅ CORRECT: Framework types
type ResourceModel struct {
    Name types.String  // Can represent null/unknown
    Age  types.Int64   // Can represent null/unknown
}
```

### 11. Incorrect Collection Conversions

**Problem:** Collection type conversions require proper element type handling.

```go
// ❌ WRONG: Direct assignment
plan.Tags = goTags  // Error: []string != types.List

// ✅ CORRECT: Proper conversion
tagValues := make([]attr.Value, len(goTags))
for i, tag := range goTags {
    tagValues[i] = types.StringValue(tag)
}

tagsList, diags := types.ListValue(types.StringType, tagValues)
resp.Diagnostics.Append(diags...)
if resp.Diagnostics.HasError() {
    return
}
plan.Tags = tagsList
```

## State Management Pitfalls

### 12. Not Handling "Not Found" in Read

**Problem:** Resource deleted outside Terraform, Read fails instead of removing from state.

```go
// ❌ WRONG: Treating not found as error
func (r *Resource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    resource, err := r.client.Get(ctx, id)
    if err != nil {
        resp.Diagnostics.AddError("Read Error", err.Error())
        return
    }
}

// ✅ CORRECT: Remove from state if not found
func (r *Resource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    resource, err := r.client.Get(ctx, id)
    if err != nil {
        if isNotFoundError(err) {
            resp.State.RemoveResource(ctx)
            return
        }
        resp.Diagnostics.AddError("Read Error", err.Error())
        return
    }
}
```

### 13. Partial State Updates

**Problem:** Only updating some fields leaves state inconsistent.

```go
// ❌ WRONG: Only setting changed fields
func (r *Resource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    state := ResourceModel{
        Name: types.StringValue(updated.Name),  // Only name
        // Missing: other fields
    }
    resp.State.Set(ctx, &state)
}

// ✅ CORRECT: Set complete state
func (r *Resource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    state := ResourceModel{
        ID:      types.StringValue(updated.ID),
        Name:    types.StringValue(updated.Name),
        Status:  types.StringValue(updated.Status),
        Created: types.StringValue(updated.Created),
    }
    resp.State.Set(ctx, &state)
}
```

## Testing Pitfalls

### 14. Using assert Instead of require

**Problem:** Tests continue after failures, hiding real issues.

```go
// ❌ WRONG: Using assert
assert.NoError(t, err)  // Continues if error
assert.Equal(t, expected, actual)  // Continues if not equal

// ✅ CORRECT: Using require
require.NoError(t, err)  // Stops if error
require.Equal(t, expected, actual)  // Stops if not equal
```

### 15. Table-Driven Tests

**Problem:** Violates Go best practices, harder to debug.

```go
// ❌ WRONG: Table-driven test
func TestValidation(t *testing.T) {
    tests := []struct {
        name  string
        input string
        want  bool
    }{
        // ...
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // ...
        })
    }
}

// ✅ CORRECT: Explicit test functions
func TestValidation_Valid(t *testing.T) {
    // Test valid case
}

func TestValidation_Invalid(t *testing.T) {
    // Test invalid case
}
```

### 16. Mixing Positive and Negative Tests

**Problem:** Makes tests harder to understand and maintain.

```go
// ❌ WRONG: Mixed positive/negative
func TestResource(t *testing.T) {
    if shouldSucceed {
        // test success
    } else {
        // test error
    }
}

// ✅ CORRECT: Separate test functions
func TestResource_Success(t *testing.T) {
    // Test success
}

func TestResource_Error(t *testing.T) {
    // Test error
}
```

## Provider Configuration Pitfalls

### 17. Not Handling Unknown Values in Configure

**Problem:** Provider tries to use unknown values during plan phase.

```go
// ❌ WRONG: Using unknown values
func (p *Provider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config ProviderModel
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)

    endpoint := config.Endpoint.ValueString()  // May be unknown during plan
    client := NewClient(endpoint)  // Error if unknown
}

// ✅ CORRECT: Check for unknown values
func (p *Provider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config ProviderModel
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    if config.Endpoint.IsUnknown() {
        resp.Diagnostics.AddWarning(
            "Unable to create client",
            "Cannot use unknown value during plan",
        )
        return
    }

    endpoint := config.Endpoint.ValueString()
    client := NewClient(endpoint)
    resp.ResourceData = client
}
```

## Plan Modifier Pitfalls

### 18. Wrong Plan Modifier for Use Case

**Problem:** Using wrong modifier or no modifier.

```go
// ❌ WRONG: No modifier on computed ID
"id": schema.StringAttribute{
    Computed: true,
    // Missing: UseStateForUnknown
},

// ❌ WRONG: UseStateForUnknown on dynamic value
"current_time": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),  // Wrong: time should update
    },
},

// ✅ CORRECT: Right modifiers
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),  // ID doesn't change
    },
},

"current_time": schema.StringAttribute{
    Computed: true,
    // No modifier: time should update each apply
},

"region": schema.StringAttribute{
    Required: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),  // Immutable field
    },
},
```

## Quick Reference Checklist

Before committing code, verify:

- ✅ All diagnostic checks present (`if resp.Diagnostics.HasError() { return }`)
- ✅ All computed IDs have `UseStateForUnknown()`
- ✅ All null/unknown values checked before `.Value*()` calls
- ✅ All CRUD operations call `resp.State.Set()` (except Delete)
- ✅ Delete does NOT call `resp.State.Set()`
- ✅ All user input has validators
- ✅ All sensitive attributes marked `Sensitive: true`
- ✅ All attributes have descriptions
- ✅ Framework types used (not Go primitives)
- ✅ "Not found" handled in Read with `RemoveResource()`
- ✅ Complete state set (not partial)
- ✅ Tests use require (not assert)
- ✅ No table-driven tests
- ✅ Positive and negative tests separated

## Summary

The most common pitfalls:
1. Not checking diagnostics
2. Missing `UseStateForUnknown()` on IDs
3. Not checking null/unknown before value access
4. Forgetting `State.Set()` in CRUD
5. Using Go primitives instead of framework types

**Follow the rules in this directory to avoid these pitfalls!**
