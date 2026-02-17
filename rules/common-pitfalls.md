# Common Pitfalls Checklist

Quick-check before committing terraform-plugin-framework code.

## Pre-Commit Checklist

### Diagnostics
- All `Plan.Get()`, `State.Get()`, `Config.Get()`, `State.Set()` calls followed by `HasError()` check and early return

### State Management
- `UseStateForUnknown()` on all stable computed attributes (IDs, creation timestamps)
- Complete state set in Create, Read, and Update (never partial state)
- Read handles "not found" with `resp.State.RemoveResource(ctx)`
- Delete does NOT call `resp.State.Set()`

### Schema
- Every attribute has exactly one of Required/Optional/Computed (never Required+Computed)
- All user input validated with appropriate validators
- Sensitive attributes marked `Sensitive: true`
- All attributes have `Description` for generated docs

### Types
- Framework types used in models (`types.String`, `types.Int64`), not Go primitives
- Null/unknown checked with `IsNull()`/`IsUnknown()` before calling `.ValueString()` etc.
- Unknown values handled in provider `Configure` (plan phase sends unknowns)

### Testing
- Resources and data sources have acceptance tests (`resource.Test`), not unit tests with mocks
- Unit tests use `require` (not `assert`)
- Positive and negative test scenarios in separate functions

### Plan Modifiers
- `UseStateForUnknown` for stable computed values, NOT for values that change on every update
- `RequiresReplace` for immutable attributes only
