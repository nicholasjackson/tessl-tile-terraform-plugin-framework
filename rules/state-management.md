# State Management Best Practices

Ensure correct state management and prevent unnecessary "known after apply" values.

## Core Rule: UseStateForUnknown for Computed Attributes

**CRITICAL**: Use `UseStateForUnknown()` plan modifier for computed attributes that don't change, especially IDs.

### Required Pattern

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Why This Matters

Without `UseStateForUnknown()`:
- Computed attributes show as "known after apply" on every plan
- Causes unnecessary resource replacements
- Confuses users about what will change
- Triggers dependent resource updates unnecessarily

### Example Impact

**Without modifier:**
```
# terraform plan
  ~ resource "example_pet" "fluffy" {
      ~ id   = "pet-123" -> (known after apply)  # Unnecessary!
        name = "Fluffy"
    }
```

**With modifier:**
```
# terraform plan
resource "example_pet" "fluffy" {
    id   = "pet-123"  # Stays as is
    name = "Fluffy"
}
```

## When to Use UseStateForUnknown

Use for:
- ✅ **Resource IDs** - Never change after creation
- ✅ **Creation timestamps** - Set once, never change
- ✅ **Computed fields from API** - Values that are stable
- ✅ **Generated names** - Computed once, then static

Don't use for:
- ❌ **Truly dynamic values** - Values that change on every apply
- ❌ **Dependent computed values** - Values that recalculate when inputs change
- ❌ **Current timestamps** - Values that should update each time

## State Consistency Rules

### 1. Always Set Complete State

```go
func (r *Resource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // ... create via API ...

    // Set ALL attributes in state
    state := ResourceModel{
        ID:      types.StringValue(result.ID),
        Name:    types.StringValue(result.Name),
        Status:  types.StringValue(result.Status),
        Created: types.StringValue(result.Created),
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

### 2. Read Refreshes State

```go
func (r *Resource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    var state ResourceModel

    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Fetch current state from API
    current, err := r.client.Get(ctx, state.ID.ValueString())
    if err != nil {
        if isNotFoundError(err) {
            // Resource deleted outside Terraform
            resp.State.RemoveResource(ctx)
            return
        }
        resp.Diagnostics.AddError("Read Error", err.Error())
        return
    }

    // Update ALL attributes with current values
    state.Name = types.StringValue(current.Name)
    state.Status = types.StringValue(current.Status)
    state.Updated = types.StringValue(current.Updated)

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

### 3. Update Overwrites State

```go
func (r *Resource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    var plan, state ResourceModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Update via API
    updated, err := r.client.Update(ctx, state.ID.ValueString(), &UpdateRequest{
        Name: plan.Name.ValueString(),
    })
    if err != nil {
        resp.Diagnostics.AddError("Update Error", err.Error())
        return
    }

    // Set complete state (not just changed fields)
    newState := ResourceModel{
        ID:      types.StringValue(updated.ID),
        Name:    types.StringValue(updated.Name),
        Status:  types.StringValue(updated.Status),
        Updated: types.StringValue(updated.Updated),
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &newState)...)
}
```

### 4. Delete Removes State

```go
func (r *Resource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    var state ResourceModel

    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    err := r.client.Delete(ctx, state.ID.ValueString())
    if err != nil && !isNotFoundError(err) {
        resp.Diagnostics.AddError("Delete Error", err.Error())
        return
    }

    // State automatically removed on success
    // DO NOT call resp.State.Set()
}
```

## Handling Resource Not Found

```go
func (r *Resource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    var state ResourceModel

    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    resource, err := r.client.Get(ctx, state.ID.ValueString())
    if err != nil {
        if isNotFoundError(err) {
            // Resource deleted outside Terraform - remove from state
            resp.State.RemoveResource(ctx)
            return
        }

        resp.Diagnostics.AddError("Read Error", err.Error())
        return
    }

    // Update state...
}
```

## Common State Patterns

### Computed ID Pattern

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

### Creation Timestamp Pattern

```go
"created_at": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},

"updated_at": schema.StringAttribute{
    Computed: true,
    // No modifier - always update
},
```

### Optional + Computed Pattern

```go
"status": schema.StringAttribute{
    Optional: true,
    Computed: true,
    Default:  stringdefault.StaticString("active"),
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

## Anti-Patterns

### ❌ Don't: Forget UseStateForUnknown on IDs

```go
// BAD: Missing plan modifier
"id": schema.StringAttribute{
    Computed: true,
    // Missing: PlanModifiers with UseStateForUnknown
},
```

### ❌ Don't: Partially set state

```go
// BAD: Only setting changed fields
func (r *Resource) Update(...) {
    state := ResourceModel{
        Name: types.StringValue(updated.Name),  // Only name
        // Missing: other fields
    }
    resp.State.Set(ctx, &state)
}
```

### ✅ Do: Set complete state

```go
// GOOD: All fields
func (r *Resource) Update(...) {
    state := ResourceModel{
        ID:      types.StringValue(updated.ID),
        Name:    types.StringValue(updated.Name),
        Status:  types.StringValue(updated.Status),
        Created: types.StringValue(updated.Created),
        Updated: types.StringValue(updated.Updated),
    }
    resp.State.Set(ctx, &state)
}
```

## Summary

- ✅ **Always** use `UseStateForUnknown()` for stable computed attributes
- ✅ **Always** set complete state in CRUD operations
- ✅ **Always** handle "not found" by removing resource from state
- ✅ Use `resp.State.RemoveResource(ctx)` when resource doesn't exist
- ❌ **Never** partially update state (always set all fields)
- ❌ **Never** call `resp.State.Set()` in Delete (state removed automatically)
- ❌ **Never** omit `UseStateForUnknown()` from resource IDs
