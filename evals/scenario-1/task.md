Modify the schema of the existing example resource in the HashiCorp scaffold to add validators and plan modifiers.

## Setup

```bash
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git .
git checkout 3f9b7d20f49724d61ffaa28f5812c347b6a3e4a1
go mod tidy
```

## Task

Update the `example_resource` in the scaffold to add the following attributes with appropriate validators and plan modifiers:

1. Add a `status` attribute (Optional, String) that only accepts values: "active", "inactive", "archived". Use a string validator.

2. Add a `priority` attribute (Optional, Int64) that must be between 1 and 10 inclusive. Use an int64 validator.

3. Add a `created_at` attribute (Computed, String) that is stable after creation. Use the appropriate plan modifier so it is preserved across updates.

4. Add an `updated_at` attribute (Computed, String) that changes on every update. Do NOT use UseStateForUnknown on this attribute.

5. Add a `slug` attribute (Required, String) that forces resource replacement if changed. Use the appropriate plan modifier.

6. The existing `id` attribute should use UseStateForUnknown since it is a stable computed value.

Ensure the project builds with `go build ./...`.
