# Diagnostics

Always check `resp.Diagnostics.HasError()` after any operation that appends diagnostics, and return early.

## When to Check

Check diagnostics and return early after:
- `req.Plan.Get()`, `req.State.Get()`, `req.Config.Get()`
- `resp.State.Set()`
- Any type conversion or attribute operation

## Pattern

```go
resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
if resp.Diagnostics.HasError() {
    return
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
