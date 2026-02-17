# Resources

Implement managed resources with Create, Read, Update, Delete (CRUD) operations and state management.

## Resource Interface

The `resource.Resource` interface defines a managed Terraform resource.

### Required Methods

```go
type Resource interface {
    // Metadata returns resource type name
    Metadata(context.Context, MetadataRequest, *MetadataResponse)

    // Schema defines resource attributes and blocks
    Schema(context.Context, SchemaRequest, *SchemaResponse)

    // Create handles resource creation
    Create(context.Context, CreateRequest, *CreateResponse)

    // Read handles reading resource state from remote API
    Read(context.Context, ReadRequest, *ReadResponse)

    // Update handles resource updates
    Update(context.Context, UpdateRequest, *UpdateResponse)

    // Delete handles resource deletion
    Delete(context.Context, DeleteRequest, *DeleteResponse)
}
```

### Optional Interfaces

```go
// ResourceWithConfigure receives provider-configured data (API client, etc.)
type ResourceWithConfigure interface {
    Resource
    Configure(context.Context, ConfigureRequest, *ConfigureResponse)
}

// ResourceWithImportState handles terraform import
type ResourceWithImportState interface {
    Resource
    ImportState(context.Context, ImportStateRequest, *ImportStateResponse)
}

// ResourceWithModifyPlan customizes plan modification
type ResourceWithModifyPlan interface {
    Resource
    ModifyPlan(context.Context, ModifyPlanRequest, *ModifyPlanResponse)
}

// ResourceWithValidateConfig validates resource configuration
type ResourceWithValidateConfig interface {
    Resource
    ValidateConfig(context.Context, ValidateConfigRequest, *ValidateConfigResponse)
}
```

## Basic Resource Implementation

### Resource Struct and Factory

```go
package resource

import (
    "context"
    "fmt"

    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure resource implements required interfaces
var (
    _ resource.Resource                = &PetResource{}
    _ resource.ResourceWithConfigure   = &PetResource{}
    _ resource.ResourceWithImportState = &PetResource{}
)

type PetResource struct {
    client *APIClient
}

func NewPetResource() resource.Resource {
    return &PetResource{}
}
```

### Metadata Method

```go
func (r *PetResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}
```

**Result:** If provider `TypeName` is "example", resource is `example_pet` in HCL.

### Schema Method

```go
func (r *PetResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Manages a pet",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Pet unique identifier",
                Computed:    true,
                PlanModifiers: []planmodifier.String{
                    stringplanmodifier.UseStateForUnknown(),
                },
            },
            "name": schema.StringAttribute{
                Description: "Pet name",
                Required:    true,
            },
            "species": schema.StringAttribute{
                Description: "Pet species (dog, cat, bird, etc.)",
                Required:    true,
                Validators: []validator.String{
                    stringvalidator.OneOf("dog", "cat", "bird", "fish"),
                },
            },
            "age": schema.Int64Attribute{
                Description: "Pet age in years",
                Optional:    true,
                Computed:    true,
                Default:     int64default.StaticInt64(0),
            },
        },
    }
}
```

See [Schema System](schema.md) for detailed schema patterns.

### Resource Model

```go
type PetResourceModel struct {
    ID      types.String `tfsdk:"id"`
    Name    types.String `tfsdk:"name"`
    Species types.String `tfsdk:"species"`
    Age     types.Int64  `tfsdk:"age"`
}
```

## CRUD Operations

### Create Method

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan PetResourceModel

    // Read plan data
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to create resource
    createReq := &CreatePetRequest{
        Name:    plan.Name.ValueString(),
        Species: plan.Species.ValueString(),
    }

    if !plan.Age.IsNull() {
        age := plan.Age.ValueInt64()
        createReq.Age = &age
    }

    pet, err := r.client.CreatePet(ctx, createReq)
    if err != nil {
        resp.Diagnostics.AddError(
            "Error creating pet",
            "Could not create pet: "+err.Error(),
        )
        return
    }

    // Map API response to state
    plan.ID = types.StringValue(pet.ID)
    plan.Name = types.StringValue(pet.Name)
    plan.Species = types.StringValue(pet.Species)
    plan.Age = types.Int64Value(int64(pet.Age))

    // Save state
    resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
}
```

**Key Points:**
1. Read plan using `req.Plan.Get()`
2. Check diagnostics: `if resp.Diagnostics.HasError() { return }`
3. Call API to create resource
4. Map API response to state model
5. Save state using `resp.State.Set()`

### Read Method

```go
func (r *PetResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    var state PetResourceModel

    // Read current state
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to get current resource state
    pet, err := r.client.GetPet(ctx, state.ID.ValueString())
    if err != nil {
        if isNotFoundError(err) {
            // Resource no longer exists, remove from state
            resp.State.RemoveResource(ctx)
            return
        }

        resp.Diagnostics.AddError(
            "Error reading pet",
            "Could not read pet ID "+state.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    // Update state with refreshed data
    state.Name = types.StringValue(pet.Name)
    state.Species = types.StringValue(pet.Species)
    state.Age = types.Int64Value(int64(pet.Age))

    // Save updated state
    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

**Key Points:**
1. Read current state using `req.State.Get()`
2. Fetch current resource state from API
3. Handle not found errors with `resp.State.RemoveResource(ctx)`
4. Update state model with API response
5. Save refreshed state

### Update Method

```go
func (r *PetResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    var plan PetResourceModel
    var state PetResourceModel

    // Read plan and current state
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to update resource
    updateReq := &UpdatePetRequest{
        ID:      state.ID.ValueString(),
        Name:    plan.Name.ValueString(),
        Species: plan.Species.ValueString(),
    }

    if !plan.Age.IsNull() {
        age := plan.Age.ValueInt64()
        updateReq.Age = &age
    }

    pet, err := r.client.UpdatePet(ctx, updateReq)
    if err != nil {
        resp.Diagnostics.AddError(
            "Error updating pet",
            "Could not update pet ID "+state.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    // Update state with response
    plan.ID = types.StringValue(pet.ID)
    plan.Name = types.StringValue(pet.Name)
    plan.Species = types.StringValue(pet.Species)
    plan.Age = types.Int64Value(int64(pet.Age))

    // Save updated state
    resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
}
```

**Key Points:**
1. Read both plan (desired state) and state (current state)
2. Call API to update resource
3. Update state model with API response
4. Save updated state

### Delete Method

```go
func (r *PetResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    var state PetResourceModel

    // Read current state
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to delete resource
    err := r.client.DeletePet(ctx, state.ID.ValueString())
    if err != nil {
        // If already deleted (404), don't error
        if !isNotFoundError(err) {
            resp.Diagnostics.AddError(
                "Error deleting pet",
                "Could not delete pet ID "+state.ID.ValueString()+": "+err.Error(),
            )
            return
        }
    }

    // State automatically removed on successful delete (don't call resp.State.Set)
}
```

**Key Points:**
1. Read current state
2. Call API to delete resource
3. Handle "already deleted" gracefully
4. Do NOT call `resp.State.Set()` - state removed automatically

## Configure Method

Receive provider-configured data (API client):

```go
func (r *PetResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
    if req.ProviderData == nil {
        return
    }

    client, ok := req.ProviderData.(*APIClient)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Resource Configure Type",
            fmt.Sprintf("Expected *APIClient, got: %T", req.ProviderData),
        )
        return
    }

    r.client = client
}
```

## Import Support

Allow importing existing resources with `terraform import`:

```go
func (r *PetResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // Import by ID
    resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
```

**Usage:**
```bash
terraform import example_pet.my_pet pet-12345
```

**Custom Import Logic:**
```go
func (r *PetResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // Parse import ID (e.g., "owner/pet-name")
    parts := strings.Split(req.ID, "/")
    if len(parts) != 2 {
        resp.Diagnostics.AddError(
            "Invalid Import ID",
            "Import ID must be in format: owner/pet-name",
        )
        return
    }

    owner := parts[0]
    name := parts[1]

    // Fetch pet by owner and name
    pet, err := r.client.GetPetByOwnerAndName(ctx, owner, name)
    if err != nil {
        resp.Diagnostics.AddError(
            "Error importing pet",
            "Could not find pet: "+err.Error(),
        )
        return
    }

    // Set state
    state := PetResourceModel{
        ID:      types.StringValue(pet.ID),
        Name:    types.StringValue(pet.Name),
        Species: types.StringValue(pet.Species),
        Age:     types.Int64Value(int64(pet.Age)),
    }

    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}
```

## State Management

### State Consistency

Terraform expects state to accurately reflect remote resource. Follow these rules:

1. **Read refreshes state** - Always fetch current remote state
2. **Create sets complete state** - Set all attributes after creation
3. **Update overwrites state** - Set complete state, not just changes
4. **Delete removes state** - State automatically cleared

### Handling Unknown Values

During plan phase, some values may be unknown (computed from other resources):

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan PetResourceModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Check for unknown values
    if plan.Name.IsUnknown() {
        resp.Diagnostics.AddError(
            "Unknown Value",
            "Cannot create pet with unknown name",
        )
        return
    }

    // Proceed with creation...
}
```

### Computed Attributes

Use `UseStateForUnknown` plan modifier for computed attributes:

```go
"id": schema.StringAttribute{
    Computed: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.UseStateForUnknown(),
    },
},
```

This prevents unnecessary replaces when computed values don't change.

See [Plan Modifiers](plan-modifiers.md) for details.

## Lifecycle Management

### RequiresReplace Plan Modifier

Force resource replacement when certain attributes change:

```go
"species": schema.StringAttribute{
    Required: true,
    PlanModifiers: []planmodifier.String{
        stringplanmodifier.RequiresReplace(),
    },
},
```

Changing `species` forces destroy + create instead of update.

### ModifyPlan Method

Custom plan modification logic:

```go
func (r *PetResource) ModifyPlan(ctx context.Context, req resource.ModifyPlanRequest, resp *resource.ModifyPlanResponse) {
    // Skip if resource is being destroyed
    if req.Plan.Raw.IsNull() {
        return
    }

    var plan PetResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Custom logic: warn if age > 20
    if !plan.Age.IsNull() && plan.Age.ValueInt64() > 20 {
        resp.Diagnostics.AddWarning(
            "Old Pet",
            "Pet age is greater than 20 years",
        )
    }

    // Modify plan if needed
    resp.Diagnostics.Append(resp.Plan.Set(ctx, &plan)...)
}
```

## Error Handling

### Diagnostics Best Practices

```go
// Error - stops execution
resp.Diagnostics.AddError(
    "Error Title",
    "Detailed error message with context: "+err.Error(),
)

// Warning - continues execution
resp.Diagnostics.AddWarning(
    "Warning Title",
    "Warning message",
)

// Attribute-specific error
resp.Diagnostics.AddAttributeError(
    path.Root("name"),
    "Invalid Name",
    "Name must not be empty",
)
```

### Retry Logic

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan PetResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Retry creation up to 3 times
    var pet *Pet
    var err error
    for i := 0; i < 3; i++ {
        pet, err = r.client.CreatePet(ctx, &CreatePetRequest{
            Name:    plan.Name.ValueString(),
            Species: plan.Species.ValueString(),
        })
        if err == nil {
            break
        }

        if !isRetryableError(err) {
            break
        }

        time.Sleep(time.Second * time.Duration(i+1))
    }

    if err != nil {
        resp.Diagnostics.AddError(
            "Error creating pet",
            "Could not create pet after retries: "+err.Error(),
        )
        return
    }

    // Continue with state setting...
}
```

## Testing Resources

Test resources with acceptance tests using `resource.Test` from `terraform-plugin-testing`:

```go
func TestAccPetResource_basic(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        CheckDestroy:             testAccCheckPetDestroy,
        Steps: []resource.TestStep{
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("example_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("example_pet.test", "species", "cat"),
                    resource.TestCheckResourceAttrSet("example_pet.test", "id"),
                ),
            },
            {
                ResourceName:      "example_pet.test",
                ImportState:       true,
                ImportStateVerify: true,
            },
        },
    })
}

func testAccPetResourceConfig(name, species string) string {
    return fmt.Sprintf(`
resource "example_pet" "test" {
  name    = %[1]q
  species = %[2]q
}
`, name, species)
}
```

See [Testing](testing.md) for comprehensive testing patterns including update, destroy, and data source tests.

## Common Patterns

### Partial Updates

Some APIs support partial updates (PATCH):

```go
func (r *PetResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    var plan, state PetResourceModel

    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Build partial update request
    updateReq := &PatchPetRequest{ID: state.ID.ValueString()}

    if !plan.Name.Equal(state.Name) {
        updateReq.Name = plan.Name.ValueStringPointer()
    }

    if !plan.Age.Equal(state.Age) {
        age := plan.Age.ValueInt64()
        updateReq.Age = &age
    }

    // Send only changed fields
    pet, err := r.client.PatchPet(ctx, updateReq)
    // ...
}
```

### Asynchronous Operations

Handle long-running operations with polling:

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // Start async operation
    operation, err := r.client.StartCreatePet(ctx, createReq)
    if err != nil {
        resp.Diagnostics.AddError("Error starting creation", err.Error())
        return
    }

    // Poll until complete
    ticker := time.NewTicker(5 * time.Second)
    defer ticker.Stop()

    timeout := time.After(10 * time.Minute)

    for {
        select {
        case <-ctx.Done():
            resp.Diagnostics.AddError("Context cancelled", ctx.Err().Error())
            return
        case <-timeout:
            resp.Diagnostics.AddError("Timeout", "Pet creation timed out")
            return
        case <-ticker.C:
            status, err := r.client.GetOperationStatus(ctx, operation.ID)
            if err != nil {
                resp.Diagnostics.AddError("Error checking status", err.Error())
                return
            }

            if status.Done {
                if status.Error != nil {
                    resp.Diagnostics.AddError("Creation failed", *status.Error)
                    return
                }

                // Operation complete, get result
                pet, err := r.client.GetPet(ctx, status.ResourceID)
                if err != nil {
                    resp.Diagnostics.AddError("Error fetching pet", err.Error())
                    return
                }

                // Set state and return
                plan.ID = types.StringValue(pet.ID)
                resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
                return
            }
        }
    }
}
```

## External References

- [Resource Interface](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/resource#Resource)
- [HashiCorp Resource Tutorial](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework/providers-plugin-framework-resource)
- [State Management](https://developer.hashicorp.com/terraform/plugin/framework/resources/state)

## Navigation

- **Previous**: [Provider](provider.md) - Provider implementation
- **Next**: [Data Sources](data-sources.md) - Data source implementation
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Data Sources](data-sources.md) to learn about read-only data source implementation.*
