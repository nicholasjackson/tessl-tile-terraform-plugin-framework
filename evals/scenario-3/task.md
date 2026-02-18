# Data Source and Import State

Add a data source and import state support to the existing example resource in the HashiCorp scaffold.

## Setup

```bash
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git .
git checkout 3f9b7d20f49724d61ffaa28f5812c347b6a3e4a1
go mod tidy
```

## Task

### Part 1: Add a data source

Create an `example_data_source` that reads an item by its `id` attribute. The scaffold already has a data source file - modify it to:

- Accept `id` as a Required String attribute
- Return `name` as a Computed String attribute (looked up by ID)
- Properly handle the case where the item is not found (add an error diagnostic)
- Check diagnostics after all Config.Get and State.Set calls

### Part 2: Add import state to the resource

Modify the existing `example_resource` to support Terraform import:

- Implement the `ResourceWithImportState` interface
- Use `resource.ImportStatePassthroughID` to import by the `id` attribute
- Add an import test step to the existing test file using `ImportState: true` and `ImportStateVerify: true`

### Part 3: Write acceptance tests

- Write an acceptance test for the data source that creates a resource first, then reads it via the data source using a reference to the resource's id
- Add an import test step to the resource test

Ensure the project builds with `go build ./...`.
