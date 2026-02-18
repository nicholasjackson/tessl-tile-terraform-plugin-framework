Add a provider-defined function to the HashiCorp scaffold that parses a composite ID string.

## Setup

```bash
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git .
git checkout 3f9b7d20f49724d61ffaa28f5812c347b6a3e4a1
go mod tidy
```

## Task

### Part 1: Create the function

Create a new file for a `parse_id` provider-defined function. The function takes a composite ID string in the format `"type:name"` and returns just the `name` portion.

Implement the `function.Function` interface:

1. **Metadata**: Set the function name to `parse_id`
2. **Definition**: Define the function with:
   - Summary and Description strings
   - One `input` parameter (String) — the composite ID to parse (e.g. `"resource:my-thing"`)
   - Return type: String (the extracted name portion)
3. **Run**: Implement the logic:
   - Read the input argument using `req.Arguments.Get`
   - Split the string on `":"`
   - If the string does not contain exactly one colon (resulting in exactly 2 parts), return a function error using `function.NewArgumentFuncError`
   - Return the second part (the name) as the result using `resp.Result.Set`

### Part 2: Register the function

Register the function in the provider by implementing the `Functions` method on the provider (implementing `provider.ProviderWithFunctions`).

### Part 3: Write tests

Write tests for the function:

1. A unit test that directly constructs a `function.RunRequest` and calls `Run`:
   - Test a valid input like `"resource:my-thing"` returns `"my-thing"`
   - Test an invalid input like `"nocolon"` returns a function error
2. An acceptance test (if possible) that uses `output "test" { value = provider::scaffolding::parse_id("resource:my-thing") }` and verifies the output value

Ensure the project builds with `go build ./...`.
