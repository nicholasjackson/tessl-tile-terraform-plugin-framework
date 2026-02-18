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

## Complete Data Source Read Pattern

A data source Read method must check diagnostics after Config.Get, handle not-found with AddError (not RemoveResource), and check diagnostics after State.Set:

```go
func (d *ExampleDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config ExampleDataSourceModel

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    item, err := d.client.GetItem(config.Id.ValueString())
    if err != nil {
        resp.Diagnostics.AddError(
            "Item Not Found",
            fmt.Sprintf("Could not find item with ID %s: %s", config.Id.ValueString(), err),
        )
        return
    }

    config.Name = types.StringValue(item.Name)

    resp.Diagnostics.Append(resp.State.Set(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }
}
```

## Error vs Warning

- **Errors** block execution -- always `return` after adding an error diagnostic
- **Warnings** are informational -- execution continues

## Attribute-Specific Errors

Use `AddAttributeError` with a path for field-level context instead of generic `AddError`.

## Anti-Pattern

Never continue execution after appending error diagnostics. Never silently ignore errors from Plan/State/Config reads.

See [Resources](../docs/resources.md) for complete CRUD examples with diagnostics.
