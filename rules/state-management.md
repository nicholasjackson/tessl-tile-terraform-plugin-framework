# State Management

Ensure correct state management and prevent unnecessary "known after apply" values.

## UseStateForUnknown for Computed Attributes

Always add `UseStateForUnknown()` plan modifier to stable computed attributes (IDs, creation timestamps). This prevents unnecessary "(known after apply)" in plans for values that don't change after creation.

Do NOT use it on attributes that change on every update (e.g., `last_modified`).

## State Consistency Rules

- **Create**: Set ALL attributes in state after the API call, including computed values from the response
- **Read**: Refresh ALL attributes from the API response. Handle not-found with `resp.State.RemoveResource(ctx)`
- **Update**: Set complete state from the API response, not just changed fields
- **Delete**: Do NOT call `resp.State.Set()` -- the framework removes state automatically

## Anti-Patterns

- Setting partial state (only some attributes) -- causes state drift
- Missing `UseStateForUnknown()` on IDs -- causes unnecessary plan diffs
- Calling `resp.State.Set()` in Delete -- not needed, state is removed automatically
- Not handling "not found" in Read -- stale resources in state

See [Resources](../docs/resources.md) for complete CRUD implementations.
See [Plan Modifiers](../docs/plan-modifiers.md) for UseStateForUnknown details.
