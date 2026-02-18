# Provider Configuration

Add provider-level configuration with environment variable fallback to the HashiCorp scaffold.

## Setup

```bash
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git .
git checkout 3f9b7d20f49724d61ffaa28f5812c347b6a3e4a1
go mod tidy
```

## Task

### Part 1: Add provider schema with configuration

Modify the existing provider in `provider.go` to accept configuration:

- Add an `endpoint` attribute (Optional, String) with a Description. This is the base URL for an API.
- Add an `api_key` attribute (Optional, Sensitive, String) with a Description. This is an authentication token.

### Part 2: Implement Configure with environment variable fallback

Implement the `Configure` method so that:

1. Read the provider config using `req.Config.Get`
2. If `endpoint` is null or unknown, fall back to the `EXAMPLE_ENDPOINT` environment variable
3. If `api_key` is null or unknown, fall back to the `EXAMPLE_API_KEY` environment variable
4. If `endpoint` is still empty after checking the environment variable, add an error diagnostic (it is required)
5. Store the configured values so resources and data sources can access them via `req.ProviderData` in their Configure methods

### Part 3: Wire provider data to resources

Update the existing `example_resource` to:

1. Implement a `Configure` method that retrieves the provider data from `req.ProviderData`
2. Handle the case where `req.ProviderData` is nil (return early, this happens during plan)
3. Type-assert the provider data and add an error diagnostic if the type is wrong

### Part 4: Write acceptance tests

Write an acceptance test that:

- Sets the provider configuration via environment variables
- Verifies the provider configures without error by running a basic plan/apply with the example resource

Ensure the project builds with `go build ./...`.
