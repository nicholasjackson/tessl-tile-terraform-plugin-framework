# Data Sources

Implement read-only data sources for querying existing infrastructure and external APIs.

## Data Source Interface

The `datasource.DataSource` interface defines a read-only Terraform data source.

### Required Methods

```go
type DataSource interface {
    // Metadata returns data source type name
    Metadata(context.Context, MetadataRequest, *MetadataResponse)

    // Schema defines data source attributes
    Schema(context.Context, SchemaRequest, *SchemaResponse)

    // Read fetches data from remote API
    Read(context.Context, ReadRequest, *ReadResponse)
}
```

### Optional Interfaces

```go
// DataSourceWithConfigure receives provider-configured data
type DataSourceWithConfigure interface {
    DataSource
    Configure(context.Context, ConfigureRequest, *ConfigureResponse)
}

// DataSourceWithValidateConfig validates configuration
type DataSourceWithValidateConfig interface {
    DataSource
    ValidateConfig(context.Context, ValidateConfigRequest, *ValidateConfigResponse)
}
```

## Basic Data Source Implementation

### Data Source Struct

```go
package datasource

import (
    "context"
    "fmt"

    "github.com/hashicorp/terraform-plugin-framework/datasource"
    "github.com/hashicorp/terraform-plugin-framework/datasource/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure data source implements required interfaces
var (
    _ datasource.DataSource              = &PetDataSource{}
    _ datasource.DataSourceWithConfigure = &PetDataSource{}
)

type PetDataSource struct {
    client *APIClient
}

func NewPetDataSource() datasource.DataSource {
    return &PetDataSource{}
}
```

### Metadata Method

```go
func (d *PetDataSource) Metadata(ctx context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}
```

**Usage in HCL:**
```hcl
data "example_pet" "my_pet" {
  id = "pet-123"
}

output "pet_name" {
  value = data.example_pet.my_pet.name
}
```

### Schema Method

```go
func (d *PetDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Fetches a pet by ID",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Pet unique identifier",
                Required:    true,
            },
            "name": schema.StringAttribute{
                Description: "Pet name",
                Computed:    true,
            },
            "species": schema.StringAttribute{
                Description: "Pet species",
                Computed:    true,
            },
            "age": schema.Int64Attribute{
                Description: "Pet age in years",
                Computed:    true,
            },
            "owner": schema.StringAttribute{
                Description: "Pet owner name",
                Computed:    true,
            },
        },
    }
}
```

**Key Points:**
- Input parameters use `Required` or `Optional`
- Output attributes use `Computed: true`
- Data sources are read-only (no `Create`, `Update`, `Delete`)

### Data Source Model

```go
type PetDataSourceModel struct {
    ID      types.String `tfsdk:"id"`
    Name    types.String `tfsdk:"name"`
    Species types.String `tfsdk:"species"`
    Age     types.Int64  `tfsdk:"age"`
    Owner   types.String `tfsdk:"owner"`
}
```

## Read Method

The `Read` method fetches data from the remote API and populates the state.

### Basic Read

```go
func (d *PetDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config PetDataSourceModel

    // Read configuration
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Fetch pet from API
    pet, err := d.client.GetPet(ctx, config.ID.ValueString())
    if err != nil {
        resp.Diagnostics.AddError(
            "Unable to Read Pet",
            "An error occurred while fetching pet ID "+config.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    // Map API response to state
    state := PetDataSourceModel{
        ID:      types.StringValue(pet.ID),
        Name:    types.StringValue(pet.Name),
        Species: types.StringValue(pet.Species),
        Age:     types.Int64Value(int64(pet.Age)),
        Owner:   types.StringValue(pet.Owner),
    }

    // Save state
    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

**Key Steps:**
1. Read configuration using `req.Config.Get()`
2. Check diagnostics
3. Call API to fetch data
4. Map response to state model
5. Save state using `resp.State.Set()`

## Configure Method

Receive provider-configured client:

```go
func (d *PetDataSource) Configure(ctx context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
    if req.ProviderData == nil {
        return
    }

    client, ok := req.ProviderData.(*APIClient)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Data Source Configure Type",
            fmt.Sprintf("Expected *APIClient, got: %T", req.ProviderData),
        )
        return
    }

    d.client = client
}
```

## Common Patterns

### Query by Attribute

Allow querying by name instead of ID:

```go
func (d *PetDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Fetches a pet by ID or name",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Pet ID (conflicts with name)",
                Optional:    true,
                Computed:    true,
            },
            "name": schema.StringAttribute{
                Description: "Pet name (conflicts with id)",
                Optional:    true,
                Computed:    true,
            },
            "species": schema.StringAttribute{
                Description: "Pet species",
                Computed:    true,
            },
            "age": schema.Int64Attribute{
                Description: "Pet age",
                Computed:    true,
            },
        },
    }
}

func (d *PetDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config PetDataSourceModel

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Validate: exactly one of id or name must be provided
    if config.ID.IsNull() && config.Name.IsNull() {
        resp.Diagnostics.AddError(
            "Missing Required Attribute",
            "Either 'id' or 'name' must be specified",
        )
        return
    }

    if !config.ID.IsNull() && !config.Name.IsNull() {
        resp.Diagnostics.AddError(
            "Conflicting Attributes",
            "Only one of 'id' or 'name' can be specified",
        )
        return
    }

    // Fetch by ID or name
    var pet *Pet
    var err error

    if !config.ID.IsNull() {
        pet, err = d.client.GetPet(ctx, config.ID.ValueString())
    } else {
        pet, err = d.client.GetPetByName(ctx, config.Name.ValueString())
    }

    if err != nil {
        resp.Diagnostics.AddError("Unable to Read Pet", err.Error())
        return
    }

    // Map to state
    state := PetDataSourceModel{
        ID:      types.StringValue(pet.ID),
        Name:    types.StringValue(pet.Name),
        Species: types.StringValue(pet.Species),
        Age:     types.Int64Value(int64(pet.Age)),
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

### List Data Source

Return multiple results:

```go
type PetsDataSourceModel struct {
    Species types.String `tfsdk:"species"`  // Filter input
    Pets    []PetModel   `tfsdk:"pets"`     // List output
}

type PetModel struct {
    ID      types.String `tfsdk:"id"`
    Name    types.String `tfsdk:"name"`
    Species types.String `tfsdk:"species"`
    Age     types.Int64  `tfsdk:"age"`
}

func (d *PetsDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Fetches all pets, optionally filtered by species",
        Attributes: map[string]schema.Attribute{
            "species": schema.StringAttribute{
                Description: "Filter by species",
                Optional:    true,
            },
            "pets": schema.ListNestedAttribute{
                Description: "List of pets",
                Computed:    true,
                NestedObject: schema.NestedAttributeObject{
                    Attributes: map[string]schema.Attribute{
                        "id": schema.StringAttribute{
                            Computed: true,
                        },
                        "name": schema.StringAttribute{
                            Computed: true,
                        },
                        "species": schema.StringAttribute{
                            Computed: true,
                        },
                        "age": schema.Int64Attribute{
                            Computed: true,
                        },
                    },
                },
            },
        },
    }
}

func (d *PetsDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config PetsDataSourceModel

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Fetch pets with optional filter
    var pets []*Pet
    var err error

    if !config.Species.IsNull() {
        pets, err = d.client.ListPetsBySpecies(ctx, config.Species.ValueString())
    } else {
        pets, err = d.client.ListAllPets(ctx)
    }

    if err != nil {
        resp.Diagnostics.AddError("Unable to List Pets", err.Error())
        return
    }

    // Map to state
    state := PetsDataSourceModel{
        Species: config.Species,
        Pets:    make([]PetModel, len(pets)),
    }

    for i, pet := range pets {
        state.Pets[i] = PetModel{
            ID:      types.StringValue(pet.ID),
            Name:    types.StringValue(pet.Name),
            Species: types.StringValue(pet.Species),
            Age:     types.Int64Value(int64(pet.Age)),
        }
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

**Usage:**
```hcl
data "example_pets" "all_cats" {
  species = "cat"
}

output "cat_names" {
  value = [for pet in data.example_pets.all_cats.pets : pet.name]
}
```

### Computed Default Values

Provide defaults when optional inputs are omitted:

```go
func (d *PetsDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config PetsDataSourceModel

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Default limit to 100 if not specified
    limit := 100
    if !config.Limit.IsNull() {
        limit = int(config.Limit.ValueInt64())
    }

    pets, err := d.client.ListPets(ctx, limit)
    // ...
}
```

## Data Source vs Resource

### When to Use Data Sources

- **Reading existing infrastructure** - Fetch VPCs, subnets, AMIs, etc.
- **External data** - Query APIs not managed by Terraform
- **Computed values** - Calculate values based on inputs
- **Reference other resources** - Get outputs from other Terraform configs

### When to Use Resources

- **Managing infrastructure** - Create, update, delete resources
- **State tracking** - Terraform tracks resource lifecycle
- **Dependencies** - Terraform plans based on dependencies

### Example: Data Source + Resource

```hcl
# Data source: fetch existing VPC
data "aws_vpc" "main" {
  default = true
}

# Resource: create subnet in VPC
resource "aws_subnet" "app" {
  vpc_id     = data.aws_vpc.main.id  # Reference data source
  cidr_block = "10.0.1.0/24"
}
```

## Validation

### ValidateConfig Method

```go
func (d *PetDataSource) ValidateConfig(ctx context.Context, req datasource.ValidateConfigRequest, resp *datasource.ValidateConfigResponse) {
    var config PetDataSourceModel

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Custom validation: exactly one of id or name
    idSet := !config.ID.IsNull()
    nameSet := !config.Name.IsNull()

    if !idSet && !nameSet {
        resp.Diagnostics.AddError(
            "Missing Required Attribute",
            "Either 'id' or 'name' must be specified",
        )
    }

    if idSet && nameSet {
        resp.Diagnostics.AddError(
            "Conflicting Attributes",
            "Only one of 'id' or 'name' can be specified",
        )
    }
}
```

### Schema Validators

Use built-in validators:

```go
"species": schema.StringAttribute{
    Optional: true,
    Validators: []validator.String{
        stringvalidator.OneOf("dog", "cat", "bird", "fish"),
    },
},
```

See [Validators](validators.md) for comprehensive validation patterns.

## Testing Data Sources

```go
func TestPetDataSource_Read(t *testing.T) {
    mockClient := &MockAPIClient{}
    mockClient.On("GetPet", mock.Anything, "pet-123").Return(&Pet{
        ID:      "pet-123",
        Name:    "Fluffy",
        Species: "cat",
        Age:     3,
        Owner:   "Alice",
    }, nil)

    dataSource := &PetDataSource{client: mockClient}

    req := datasource.ReadRequest{
        Config: /* config with id="pet-123" */,
    }
    resp := &datasource.ReadResponse{
        State: tfsdk.State{},
    }

    dataSource.Read(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
    mockClient.AssertExpectations(t)

    var state PetDataSourceModel
    resp.State.Get(context.Background(), &state)
    require.Equal(t, "pet-123", state.ID.ValueString())
    require.Equal(t, "Fluffy", state.Name.ValueString())
    require.Equal(t, "cat", state.Species.ValueString())
}
```

See [Testing](testing.md) for comprehensive testing patterns.

## Error Handling

### Not Found Errors

```go
pet, err := d.client.GetPet(ctx, config.ID.ValueString())
if err != nil {
    if isNotFoundError(err) {
        resp.Diagnostics.AddError(
            "Pet Not Found",
            "No pet exists with ID "+config.ID.ValueString(),
        )
    } else {
        resp.Diagnostics.AddError(
            "Unable to Read Pet",
            "An unexpected error occurred: "+err.Error(),
        )
    }
    return
}
```

### Empty Results

```go
pets, err := d.client.ListPets(ctx)
if err != nil {
    resp.Diagnostics.AddError("Unable to List Pets", err.Error())
    return
}

if len(pets) == 0 {
    resp.Diagnostics.AddWarning(
        "No Pets Found",
        "The query returned no results",
    )
}
```

## External References

- [DataSource Interface](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/datasource#DataSource)
- [HashiCorp Data Source Tutorial](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework/providers-plugin-framework-data-source)

## Navigation

- **Previous**: [Resources](resources.md) - Resource implementation
- **Next**: [Schema System](schema.md) - Schema design patterns
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Schema System](schema.md) to learn about designing schemas with attributes, blocks, and nested structures.*
