# Resource CRUD with API Client

Add a new Pet resource to the HashiCorp scaffold that manages pets via the Swagger Petstore API.

## Setup

```bash
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git .
git checkout 3f9b7d20f49724d61ffaa28f5812c347b6a3e4a1
go mod tidy
```

## Task

Add a `petstore_pet` resource with full CRUD operations. Keep the existing scaffold example resource as-is and add the new resource alongside it.

The API does not require authentication. The base URL is: https://petstore.swagger.io/v2

Create an API client and implement the resource with:
- Create (POST /pet)
- Read (GET /pet/{petId})
- Update (PUT /pet)
- Delete (DELETE /pet/{petId})

### Pet Model

```json
{
  "Pet": {
    "type": "object",
    "required": ["name", "photoUrls"],
    "properties": {
      "id": {"type": "integer", "format": "int64"},
      "name": {"type": "string"},
      "photoUrls": {"type": "array", "items": {"type": "string"}},
      "status": {"type": "string", "enum": ["available", "pending", "sold"]}
    }
  }
}
```

Register the new resource in the provider. Write an acceptance test for the resource. Ensure the project builds with `go build ./...`.
