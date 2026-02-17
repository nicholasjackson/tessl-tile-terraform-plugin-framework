Create a Terraform provider for the following API using terraform-plugin-framework.

The API does not require authentication.
The base URL is: {{PETSTORE_URL}}

The provider should accept the endpoint as a configurable attribute, defaulting to the base URL above. The endpoint can also be set via the PETSTORE_ENDPOINT environment variable.

Implement resources and data sources for the API endpoints, along with acceptance tests using terraform-plugin-testing.