# Diagnostics Best Practices

Always check and handle diagnostics correctly in terraform-plugin-framework code.

## Core Rule: Always Check Diagnostics

**CRITICAL**: After any operation that populates diagnostics, check `resp.Diagnostics.HasError()` and return early if errors exist.

### Required Pattern

```go
func (r *Resource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan ResourceModel

    // Read plan
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return  // ALWAYS return early
    }

    // Continue only if no errors...
}
```

### Why This Matters

Continuing after diagnostic errors leads to:
- Runtime panics (accessing null/invalid data)
- Confusing error messages
- State corruption
- Unpredictable behavior

## When to Check Diagnostics

Check after:
1. **State/Plan/Config reads**: `req.Plan.Get()`, `req.State.Get()`, `req.Config.Get()`
2. **Type conversions**: `types.ListValue()`, `types.ObjectValueFrom()`, etc.
3. **Attribute operations**: `resp.State.Set()`, `resp.Plan.Set()`
4. **Custom operations**: Any operation that appends to diagnostics

## Error vs Warning

### Errors

Block execution - user must fix:

```go
resp.Diagnostics.AddError(
    "Error Title",
    "Detailed error message with context",
)
return  // Must return after error
```

### Warnings

Continue execution - informational:

```go
resp.Diagnostics.AddWarning(
    "Warning Title",
    "Warning message",
)
// Can continue execution
```

## Attribute-Specific Errors

Provide context with attribute paths:

```go
resp.Diagnostics.AddAttributeError(
    path.Root("name"),
    "Invalid Name",
    "Name must not be empty",
)

resp.Diagnostics.AddAttributeError(
    path.Root("disks").AtListIndex(0).AtName("size"),
    "Invalid Disk Size",
    "Size must be positive",
)
```

## Anti-Patterns

### ❌ Don't: Skip diagnostic check

```go
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
// Missing: if resp.Diagnostics.HasError() { return }

// This will panic if Get() failed
name := plan.Name.ValueString()  // PANIC!
```

### ❌ Don't: Check only specific errors

```go
if err := doSomething(); err != nil {
    resp.Diagnostics.AddError("Error", err.Error())
    // Missing: return
}
// Code continues even after error!
```

### ✅ Do: Always check and return

```go
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
if resp.Diagnostics.HasError() {
    return
}

if err := doSomething(); err != nil {
    resp.Diagnostics.AddError("Error", err.Error())
    return
}
```

## Complete Example

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan PetResourceModel

    // Step 1: Read plan with diagnostic check
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Step 2: Validate with diagnostic check
    if plan.Name.IsNull() || plan.Name.ValueString() == "" {
        resp.Diagnostics.AddAttributeError(
            path.Root("name"),
            "Missing Name",
            "Name is required",
        )
        return
    }

    // Step 3: API call with error handling
    pet, err := r.client.CreatePet(ctx, &CreatePetRequest{
        Name:    plan.Name.ValueString(),
        Species: plan.Species.ValueString(),
    })
    if err != nil {
        resp.Diagnostics.AddError(
            "API Error",
            fmt.Sprintf("Failed to create pet: %s", err.Error()),
        )
        return
    }

    // Step 4: Set state with diagnostic check
    state := PetResourceModel{
        ID:      types.StringValue(pet.ID),
        Name:    types.StringValue(pet.Name),
        Species: types.StringValue(pet.Species),
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }
}
```

## Summary

- ✅ **Always** check `resp.Diagnostics.HasError()` after operations
- ✅ **Always** return early if errors exist
- ✅ Use `AddAttributeError` for attribute-specific errors
- ✅ Use `AddWarning` for non-blocking issues
- ❌ **Never** continue execution after adding errors
- ❌ **Never** skip diagnostic checks
