# Testing Standards

Follow Terraform provider testing conventions for terraform-plugin-framework code.

## Acceptance Tests for Resources and Data Sources

All resources and data sources MUST have acceptance tests using `resource.Test` from `terraform-plugin-testing`. This is the standard convention across all major Terraform providers.

Do NOT unit test resource CRUD methods with mock API clients.

### Required Scenarios per Resource

- `TestAcc<Resource>_basic` -- create and read
- `TestAcc<Resource>_update` -- create then update
- `TestAcc<Resource>_import` -- import state verification

### Key Components

- `ProtoV6ProviderFactories` for provider setup
- `CheckDestroy` to verify cleanup
- `resource.ComposeAggregateTestCheckFunc` for assertions
- HCL config helper functions using `fmt.Sprintf`

## Unit Tests for Helpers Only

Unit tests are appropriate for:
- Custom validators
- Custom plan modifiers
- Provider functions
- Expand/flatten utilities, parsers

Use `testify/require` for assertions (not `assert` -- require stops on failure).

### Provider Function Unit Tests

Provider functions MUST have unit tests that directly call the `Run` method. Construct `function.RunRequest` with `function.NewArgumentsData` and `function.RunResponse` with `function.NewResultData`, then assert the result:

```go
func TestParseIdFunction_ValidInput(t *testing.T) {
    f := NewParseIdFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue("resource:my-thing"),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.Nil(t, resp.Error)
    var result string
    resp.Result.Get(context.Background(), &result)
    require.Equal(t, "my-thing", result)
}
```

Always test both valid inputs and invalid/error inputs in separate test functions.

## Style

- Avoid table-driven tests -- write explicit test functions per scenario
- Separate positive and negative tests into different functions
- Naming: `TestAcc<Resource>_<scenario>` for acceptance, `Test<Function>_<scenario>` for unit

See [Testing](../docs/testing.md) for complete examples, config helpers, and CheckDestroy patterns.
