Add an ephemeral resource to this existing Terraform provider.

Create an `example_token` ephemeral resource that generates a temporary token. The ephemeral resource should:

- Accept a `name` attribute (Required, String) in the config — the name of the secret or token to retrieve
- Accept a `ttl` attribute (Optional, Int64) in the config — time-to-live in seconds, defaults to 3600
- Return a `token` attribute (Computed, String, Sensitive) in the result — the generated token value
- Return an `expires_at` attribute (Computed, String) in the result — an RFC3339 timestamp

Implement the `Open` method to:
1. Read the config and check diagnostics
2. Generate a token value (a UUID or random string is fine)
3. Compute `expires_at` as current time plus `ttl` seconds, formatted as RFC3339
4. Set the result and check diagnostics

Implement the `Close` method (can be a no-op with a log message).

Register the ephemeral resource in the provider by implementing the `EphemeralResources` method (implementing `provider.ProviderWithEphemeralResources`).

Write a unit test that directly calls Open and verifies the result contains a non-empty token and a valid expires_at timestamp.

Ensure the project builds with `go build ./...`.