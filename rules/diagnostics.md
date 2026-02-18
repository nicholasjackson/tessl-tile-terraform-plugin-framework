# Diagnostics

Always check `resp.Diagnostics.HasError()` after any operation that appends diagnostics, and return early.

## When to Check

Check diagnostics and return early after:
- `req.Plan.Get()`, `req.State.Get()`, `req.Config.Get()`
- `resp.State.Set()`
- Any type conversion or attribute operation

## Pattern

Reading plan (resources):
```go
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
if resp.Diagnostics.HasError() {
    return
}
```

Reading config (data sources):
```go
resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
if resp.Diagnostics.HasError() {
    return
}
```

Setting state (always check, even as the last statement in a function):
```go
resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
if resp.Diagnostics.HasError() {
    return
}
```

## Data Source Not-Found Handling

Data sources must always return an error when the requested item is not found. Unlike resources (which use `RemoveResource`), a data source that cannot find its item is a hard error:

```go
// In a data source Read method:
item, err := client.GetItem(data.Id.ValueString())
if err != nil {
    resp.Diagnostics.AddError(
        "Item Not Found",
        fmt.Sprintf("Could not find item with ID %s: %s", data.Id.ValueString(), err),
    )
    return
}
```

Never silently return or leave state empty when a data source lookup fails.

## Error vs Warning

- **Errors** block execution -- always `return` after adding an error diagnostic
- **Warnings** are informational -- execution continues

## Attribute-Specific Errors

Use `AddAttributeError` with a path for field-level context instead of generic `AddError`.

## Anti-Pattern

Never continue execution after appending error diagnostics. Never silently ignore errors from Plan/State/Config reads.

See [Resources](../docs/resources.md) for complete CRUD examples with diagnostics.
