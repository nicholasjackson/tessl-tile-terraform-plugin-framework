# Schema Design

Design clear, consistent schemas with proper constraints, validators, and modifiers.

## Attribute Constraints

Every attribute must have exactly one of: `Required`, `Optional`, or `Computed`.

- `Required` -- user must provide; cannot be combined with `Computed`
- `Optional` -- user may provide
- `Computed` -- provider sets; user cannot configure
- `Optional` + `Computed` -- user can provide, provider sets a default if not

`Required` + `Computed` is invalid and will error.

## Required Modifiers

- `UseStateForUnknown()` on all stable computed attributes (IDs, creation timestamps)
- `RequiresReplace()` on immutable attributes that force resource recreation

## Validators

Always validate user input on `Required` and `Optional` attributes:
- String: `LengthAtLeast`, `LengthBetween`, `OneOf`, regex patterns
- Number: `Between`, `AtLeast`, `AtMost`
- Cross-attribute: `ExactlyOneOf`, `AtLeastOneOf`, `ConflictsWith`

## Required Metadata

- `Description` on every attribute (used for generated provider docs)
- `Sensitive: true` on credentials, tokens, passwords, API keys
- `DeprecatedMessage` when replacing an attribute

## Schema Organization

Group related attributes logically: identity first (name, ID), then configuration, then computed/read-only fields.

See [Schema](../docs/schema.md) for full attribute type reference.
See [Validators](../docs/validators.md) for built-in and custom validator patterns.
See [Plan Modifiers](../docs/plan-modifiers.md) for modifier patterns.
