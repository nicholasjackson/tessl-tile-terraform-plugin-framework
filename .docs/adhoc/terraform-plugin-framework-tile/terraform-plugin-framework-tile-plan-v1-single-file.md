# Terraform Plugin Framework Tile Implementation Plan

**Created**: 2026-02-16
**Last Updated**: 2026-02-16
**Type**: Documentation Creation
**Target**: Comprehensive Tessl tile for terraform-plugin-framework

## Overview

Create comprehensive documentation for `github.com/hashicorp/terraform-plugin-framework` (v1.17.0) in a Tessl tile to enable coding agents to build Terraform providers effectively. The documentation will cover all major framework capabilities with practical code examples, testing patterns, schema design guidance, common pitfalls, and Go-specific integration patterns.

**Purpose**: Help coding agents understand how to use terraform-plugin-framework to build Terraform providers, covering everything from basic setup to advanced capabilities like functions and ephemeral resources.

**Approach**: Replace the template in `docs/index.md` with comprehensive, well-structured documentation organized into 12 major sections with a detailed table of contents, code examples, pitfall warnings, and cross-references.

## Current State Analysis

### Existing Files:

**File**: `tile.json:1-7`
```json
{
  "name": "nicholasjackson/terraform-plugin-framework",
  "version": "0.1.0",
  "summary": "terraform-plugin-framework is a module for building Terraform providers...",
  "describes": "pkg:golang/github.com/hashicorp/terraform-plugin-framework",
  "docs": "docs/index.md"
}
```
- ✅ Correctly configured
- ✅ Points to docs/index.md
- ✅ Describes the correct package

**File**: `docs/index.md:1-24` (Current Template)
```markdown
# github.com/hashicorp/terraform-plugin-framework Guide

This tile documents the `github.com/hashicorp/terraform-plugin-framework` package.

## Overview
TODO: Describe what this package does and when to use it.

## Installation
TODO: Installation instructions

## Basic Usage
TODO: Provide basic usage examples.

## API Reference
TODO: Document key APIs, classes, and functions.

## Best Practices
TODO: Share tips and best practices for using this package.
```
- ❌ Template with TODOs - needs comprehensive content
- Target: ~3000-4000 lines of documentation

**File**: `.claude/settings.local.json:1-7`
- ✅ Permissions configured for docs.tessl.io

### What's Missing:

1. **Content**: All sections are empty templates
2. **Structure**: No detailed table of contents or navigation
3. **Examples**: No code examples demonstrating framework usage
4. **Testing**: No testing patterns or guidance
5. **Pitfalls**: No common gotchas or debugging tips
6. **Go Integration**: No Go-specific patterns
7. **Comprehensive Coverage**: Only basic sections, not all framework capabilities

## Desired End State

A comprehensive `docs/index.md` file (~3000-4000 lines) that contains:

### Structure:
- Detailed table of contents with jump links
- 12 major sections covering all framework capabilities
- Clear hierarchy (h1 → h2 → h3 structure)
- Cross-references between related concepts

### Content per Section:
- **Conceptual explanation**: What it is, why it exists, when to use
- **Key interfaces/types**: Important APIs to implement
- **Code examples**: 20-50 line focused examples (not full providers)
- **Common pitfalls**: What goes wrong, how to avoid/fix
- **Testing patterns**: How to test this capability
- **Related concepts**: Links to other relevant sections

### 12 Major Sections:
1. Overview & Quick Start
2. Provider Implementation
3. Resources
4. Data Sources
5. Schema System
6. Type System
7. Validators
8. Plan Modifiers
9. Functions
10. Actions & Ephemeral Resources
11. Testing Patterns
12. Common Pitfalls & Best Practices

### Verification:
- File exists at `docs/index.md`
- File is valid markdown
- All sections have content (no TODOs remaining)
- Code examples are syntactically correct Go
- Internal links work correctly
- External references are valid URLs

## What We're NOT Doing

To keep scope manageable and focused:

❌ **Not creating a full example provider** - Code snippets only
❌ **Not including migration content** - terraform-plugin-sdk migration guide out of scope
❌ **Not documenting general Go patterns** - Reference separate Go best practices tile
❌ **Not covering terraform-plugin-go** - Lower-level protocol layer (abstracted by framework)
❌ **Not teaching Terraform language** - HCL/configuration syntax out of scope
❌ **Not documenting every single package** - Focus on developer-facing APIs
❌ **Not creating tests** - Pure documentation, no code to test

## Implementation Approach

**Strategy**: Build documentation section by section in logical phases, grouping related content together. Each phase is self-contained and can be verified independently.

**Content Sources**:
- terraform-plugin-framework package documentation (pkg.go.dev)
- HashiCorp Developer docs (developer.hashicorp.com)
- Code examples adapted from official sources
- Common patterns from scaffolding template
- Best practices from Go development guidelines

**Format**: Single markdown file with:
- Markdown headers for structure (## for major sections, ### for subsections)
- Code blocks with syntax highlighting (```go)
- Inline code for types/functions (`provider.Provider`)
- Blockquotes for warnings/tips (> ⚠️ **Warning**: ...)
- Lists for step-by-step guidance
- Tables for API references
- Links for cross-references and external resources

---

## Phase 1: Foundation & Core Concepts

### Overview

Establish the documentation foundation with table of contents, overview, quick start, and provider implementation. These are the entry points agents need to understand what the framework is and how to begin.

### Content to Create:

#### 1.1 Document Header & Table of Contents
**File**: `docs/index.md:1-100`

Create:
- Title and introduction
- Comprehensive table of contents with internal links
- Quick navigation to all 12 sections
- Version information (v1.17.0)
- Links to official resources

**Example structure:**
```markdown
# Terraform Plugin Framework Guide

Comprehensive guide for building Terraform providers using `github.com/hashicorp/terraform-plugin-framework` (v1.17.0).

## Table of Contents

1. [Overview & Quick Start](#overview--quick-start)
   - [What is terraform-plugin-framework](#what-is-terraform-plugin-framework)
   - [When to Use](#when-to-use)
   - [Installation](#installation)
   - [Quick Start](#quick-start)
2. [Provider Implementation](#provider-implementation)
   ... (complete TOC for all 12 sections)
```

**Success criteria**: TOC is complete, all links work

#### 1.2 Overview & Quick Start Section
**File**: `docs/index.md:101-350`

Create content covering:
- **What is terraform-plugin-framework**: SDK for building Terraform providers, abstracts terraform-plugin-go
- **When to Use**: Building new providers (not migration), vs plugin-sdk comparison
- **Installation**: Go module installation, minimum Go version (1.24+)
- **Quick Start**: Minimal provider setup in 4-5 steps

**Code example needed:**
```go
// Minimal provider struct
package provider

import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/provider"
    "github.com/hashicorp/terraform-plugin-framework/provider/schema"
)

type myProvider struct {
    // Provider-specific fields
    version string
}

func New(version string) func() provider.Provider {
    return func() provider.Provider {
        return &myProvider{
            version: version,
        }
    }
}

// Implement provider.Provider interface
func (p *myProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "myprovider"
    resp.Version = p.version
}

func (p *myProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "My example provider",
        Attributes: map[string]schema.Attribute{
            "api_token": schema.StringAttribute{
                Description: "API token for authentication",
                Optional:    true,
                Sensitive:   true,
            },
        },
    }
}

func (p *myProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    // Provider configuration logic
}

func (p *myProvider) Resources(_ context.Context) []func() resource.Resource {
    return []func() resource.Resource{
        // List of resources
    }
}

func (p *myProvider) DataSources(_ context.Context) []func() datasource.DataSource {
    return []func() datasource.DataSource{
        // List of data sources
    }
}
```

**Pitfalls to include:**
- Forgetting to implement all interface methods
- Not returning provider factory function
- Confusion between TypeName (provider name) and resource names

#### 1.3 Provider Implementation Section
**File**: `docs/index.md:351-650`

Create comprehensive provider documentation:
- **Provider Interface**: Methods to implement (Metadata, Schema, Configure, Resources, DataSources, Functions)
- **Provider Configuration**: Schema for provider block, sensitive values
- **Provider Data**: Passing configured client to resources/data sources
- **Provider Server**: Using `providerserver.NewProtocol6()` or `NewProtocol5()`

**Code examples needed:**
1. Provider configuration struct
2. Configure method with client setup
3. Passing provider data to resources
4. Provider server setup in main.go

**Example - Configure method:**
```go
type myProviderData struct {
    APIToken string
    Client   *http.Client
}

func (p *myProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config myProviderData

    // Read configuration from req.Config
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Validate configuration
    if config.APIToken == "" {
        resp.Diagnostics.AddError(
            "Missing API Token",
            "The provider cannot be configured without an API token.",
        )
        return
    }

    // Create client
    client := &http.Client{
        Timeout: 30 * time.Second,
    }

    // Make provider data available to resources
    resp.DataSourceData = &myProviderData{
        APIToken: config.APIToken,
        Client:   client,
    }
    resp.ResourceData = &myProviderData{
        APIToken: config.APIToken,
        Client:   client,
    }
}
```

**Pitfalls to include:**
- Not checking diagnostics before proceeding
- Forgetting to set DataSourceData/ResourceData
- Configuration validation errors vs runtime errors
- Environment variable handling for credentials

### Testing for This Phase:

**No automated testing** - Documentation only

**Manual verification**:
- [ ] Read through all content for clarity
- [ ] Verify code examples compile (copy/paste test)
- [ ] Check internal TOC links work
- [ ] Confirm no TODOs remain in Phase 1 sections
- [ ] Ensure Go syntax highlighting works
- [ ] Verify external links are valid

### Success Criteria:

#### Automated Verification:
N/A - Documentation task, no automated tests

#### Manual Verification:
- [ ] Table of contents created with all 12 sections listed
- [ ] Overview section complete with installation and quick start
- [ ] Provider implementation section covers all interface methods
- [ ] At least 3 code examples included showing provider setup
- [ ] Common pitfalls documented for provider implementation
- [ ] All internal links in TOC work correctly
- [ ] No placeholder TODOs remain in Phase 1 content
- [ ] Markdown renders correctly (test with viewer)
- [ ] Code examples are syntactically valid Go

---

## Phase 2: Resources & Data Sources

### Overview

Document the core of provider functionality: resources (CRUD operations) and data sources (read-only queries). These are the primary interfaces agents will implement when building providers.

### Content to Create:

#### 2.1 Resources Section
**File**: `docs/index.md:651-1100`

Create comprehensive resource documentation:
- **Resource Interface**: Methods to implement (Metadata, Schema, Create, Read, Update, Delete, ImportState)
- **Resource Lifecycle**: CRUD operations and state management
- **Resource Schema**: Defining resource structure
- **State Management**: Reading/writing state, handling drift
- **Import Support**: Implementing ImportState

**Code examples needed:**
1. Basic resource struct and interface implementation
2. Create method with state setting
3. Read method with API call
4. Update method with partial updates
5. Delete method with error handling
6. ImportState implementation

**Example - Resource structure:**
```go
package resource

import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure implementation satisfies interfaces
var (
    _ resource.Resource              = &exampleResource{}
    _ resource.ResourceWithConfigure = &exampleResource{}
    _ resource.ResourceWithImportState = &exampleResource{}
)

type exampleResource struct {
    client *http.Client
}

type exampleResourceModel struct {
    ID          types.String `tfsdk:"id"`
    Name        types.String `tfsdk:"name"`
    Description types.String `tfsdk:"description"`
    Tags        types.Map    `tfsdk:"tags"`
}

func NewExampleResource() resource.Resource {
    return &exampleResource{}
}

func (r *exampleResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_example"
}

func (r *exampleResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Manages an example resource",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Resource identifier",
                Computed:    true,
            },
            "name": schema.StringAttribute{
                Description: "Resource name",
                Required:    true,
            },
            "description": schema.StringAttribute{
                Description: "Resource description",
                Optional:    true,
            },
            "tags": schema.MapAttribute{
                Description: "Resource tags",
                Optional:    true,
                ElementType: types.StringType,
            },
        },
    }
}

func (r *exampleResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
    if req.ProviderData == nil {
        return
    }

    client, ok := req.ProviderData.(*http.Client)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Resource Configure Type",
            fmt.Sprintf("Expected *http.Client, got: %T", req.ProviderData),
        )
        return
    }

    r.client = client
}

func (r *exampleResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan exampleResourceModel

    // Read Terraform plan data
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to create resource
    // apiResponse, err := r.client.CreateResource(...)
    // if err != nil {
    //     resp.Diagnostics.AddError("API Error", err.Error())
    //     return
    // }

    // Map API response to model
    // plan.ID = types.StringValue(apiResponse.ID)

    // Save state
    resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
}

func (r *exampleResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    var state exampleResourceModel

    // Read current state
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to read resource
    // apiResponse, err := r.client.GetResource(state.ID.ValueString())
    // if err != nil {
    //     resp.Diagnostics.AddError("API Error", err.Error())
    //     return
    // }

    // Update state from API response
    // state.Name = types.StringValue(apiResponse.Name)

    // Save updated state
    resp.Diagnostics.Append(resp.State.Set(ctx, &state)...)
}

func (r *exampleResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    var plan exampleResourceModel

    // Read plan
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to update resource
    // err := r.client.UpdateResource(plan.ID.ValueString(), ...)

    // Save updated state
    resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
}

func (r *exampleResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    var state exampleResourceModel

    // Read state
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Call API to delete resource
    // err := r.client.DeleteResource(state.ID.ValueString())
    // if err != nil {
    //     resp.Diagnostics.AddError("API Error", err.Error())
    //     return
    // }

    // State is automatically cleared on successful delete
}

func (r *exampleResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // Import by ID
    resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
```

**Pitfalls to include:**
- Forgetting to check diagnostics
- Not setting state in Create/Update
- Handling API errors vs validation errors
- Partial update challenges
- Import ID format issues

#### 2.2 Data Sources Section
**File**: `docs/index.md:1101-1350`

Create data source documentation:
- **DataSource Interface**: Methods (Metadata, Schema, Read)
- **Read-Only Operations**: No Create/Update/Delete
- **Configuration vs Computed**: Input arguments vs output attributes
- **Multiple Results**: Handling lists of data

**Code example:**
```go
type exampleDataSource struct {
    client *http.Client
}

type exampleDataSourceModel struct {
    ID     types.String `tfsdk:"id"`
    Name   types.String `tfsdk:"name"`
    Filter types.String `tfsdk:"filter"`
}

func (d *exampleDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Fetches information about an example resource",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Resource identifier",
                Required:    true,
            },
            "name": schema.StringAttribute{
                Description: "Resource name",
                Computed:    true,
            },
            "filter": schema.StringAttribute{
                Description: "Optional filter",
                Optional:    true,
            },
        },
    }
}

func (d *exampleDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config exampleDataSourceModel

    // Read configuration
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Query API
    // apiResponse, err := d.client.GetResource(config.ID.ValueString())

    // Set computed attributes
    // config.Name = types.StringValue(apiResponse.Name)

    // Save state
    resp.Diagnostics.Append(resp.State.Set(ctx, &config)...)
}
```

**Pitfalls:**
- Using Required for computed attributes (should be Computed)
- Trying to implement Create/Update/Delete (not applicable)
- Not handling cases where data doesn't exist

### Testing for This Phase:

**Manual verification:**
- [ ] Read through resource section for completeness
- [ ] Verify CRUD examples are clear
- [ ] Check data source examples compile
- [ ] Confirm pitfalls are highlighted
- [ ] Ensure cross-references to schema section work
- [ ] Validate import state guidance is clear

### Success Criteria:

#### Automated Verification:
N/A

#### Manual Verification:
- [ ] Resources section covers all lifecycle methods (Create, Read, Update, Delete, Import)
- [ ] At least 5 code examples showing resource patterns
- [ ] Data sources section explains read-only nature
- [ ] Import state implementation documented with examples
- [ ] Common pitfalls listed for both resources and data sources
- [ ] State management patterns explained clearly
- [ ] Error handling patterns demonstrated
- [ ] No TODOs remain in Phase 2 sections

---

## Phase 3: Schema & Type Systems

### Overview

Document how to define the structure of providers, resources, and data sources using schemas and the type system. Critical for agents to understand how to model Terraform configuration.

### Content to Create:

#### 3.1 Schema System Section
**File**: `docs/index.md:1351-1750`

Create schema documentation:
- **Schema Basics**: Attributes, blocks, nesting
- **Attribute Types**: String, Int64, Bool, Float64, Number, List, Map, Set, Object, Dynamic
- **Attribute Modifiers**: Required, Optional, Computed, Sensitive
- **Nested Attributes**: SingleNested, ListNested, MapNested, SetNested
- **Blocks**: Repeatable configuration blocks
- **Schema Validation**: Built-in validators

**Code examples:**
1. Simple schema with basic attributes
2. Schema with nested attributes
3. Schema with blocks
4. Schema with list of objects
5. Schema with validators

**Example:**
```go
schema.Schema{
    Description: "Example resource with various schema patterns",
    Attributes: map[string]schema.Attribute{
        // Basic attributes
        "id": schema.StringAttribute{
            Computed: true,
        },
        "name": schema.StringAttribute{
            Required: true,
            Description: "Resource name",
            Validators: []validator.String{
                stringvalidator.LengthBetween(1, 255),
            },
        },

        // Optional with default
        "enabled": schema.BoolAttribute{
            Optional: true,
            Computed: true,
            Default:  booldefault.StaticBool(true),
        },

        // Sensitive value
        "api_key": schema.StringAttribute{
            Optional:  true,
            Sensitive: true,
        },

        // Collections
        "tags": schema.MapAttribute{
            Optional:    true,
            ElementType: types.StringType,
        },

        "ports": schema.ListAttribute{
            Required:    true,
            ElementType: types.Int64Type,
        },

        // Nested single object
        "config": schema.SingleNestedAttribute{
            Optional: true,
            Attributes: map[string]schema.Attribute{
                "host": schema.StringAttribute{
                    Required: true,
                },
                "port": schema.Int64Attribute{
                    Required: true,
                },
            },
        },

        // Nested list of objects
        "rules": schema.ListNestedAttribute{
            Optional: true,
            NestedObject: schema.NestedAttributeObject{
                Attributes: map[string]schema.Attribute{
                    "name": schema.StringAttribute{
                        Required: true,
                    },
                    "priority": schema.Int64Attribute{
                        Required: true,
                    },
                },
            },
        },
    },

    // Blocks (alternative to nested attributes)
    Blocks: map[string]schema.Block{
        "connection": schema.SingleNestedBlock{
            Description: "Connection configuration",
            Attributes: map[string]schema.Attribute{
                "type": schema.StringAttribute{
                    Required: true,
                },
            },
        },
    },
}
```

**Pitfalls:**
- Computed without Optional (can't be set by user)
- Required with Default (conflicting)
- Forgetting ElementType for collections
- Blocks vs nested attributes confusion
- Not marking sensitive values as Sensitive

#### 3.2 Type System Section
**File**: `docs/index.md:1751-2050`

Create type system documentation:
- **Framework Types**: types.String, types.Int64, types.Bool, types.Float64, types.Number, types.List, types.Map, types.Set, types.Object, types.Dynamic
- **Value vs Type**: Understanding types.StringType vs types.StringValue()
- **Null vs Unknown**: Handling missing and computed values
- **Type Conversions**: Between framework types and Go types
- **Custom Types**: Extending the type system

**Code examples:**
1. Working with basic types
2. Null and unknown handling
3. Converting to Go types
4. Custom type implementation

**Example:**
```go
// Working with framework types in resource model
type myResourceModel struct {
    Name        types.String `tfsdk:"name"`
    Port        types.Int64  `tfsdk:"port"`
    Enabled     types.Bool   `tfsdk:"enabled"`
    Tags        types.Map    `tfsdk:"tags"`    // Map[String]String
    Items       types.List   `tfsdk:"items"`   // List[String]
    UniqueItems types.Set    `tfsdk:"unique"`  // Set[String]
}

// In CRUD methods, check for null/unknown
func (r *myResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan myResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)

    // Check if value is null or unknown
    if plan.Name.IsNull() {
        resp.Diagnostics.AddError("Name Required", "Name cannot be null")
        return
    }

    if plan.Name.IsUnknown() {
        // Unknown values shouldn't appear in plan, but defensively check
        resp.Diagnostics.AddError("Name Unknown", "Name value is unknown")
        return
    }

    // Convert to Go string for API call
    nameStr := plan.Name.ValueString()
    portInt := plan.Port.ValueInt64()
    enabledBool := plan.Enabled.ValueBool()

    // Working with map
    var tagsMap map[string]string
    if !plan.Tags.IsNull() {
        resp.Diagnostics.Append(plan.Tags.ElementsAs(ctx, &tagsMap, false)...)
    }

    // Working with list
    var itemsList []string
    if !plan.Items.IsNull() {
        resp.Diagnostics.Append(plan.Items.ElementsAs(ctx, &itemsList, false)...)
    }

    // Setting computed values
    plan.ComputedField = types.StringValue("computed_value")

    // Setting null explicitly
    plan.OptionalField = types.StringNull()

    resp.Diagnostics.Append(resp.State.Set(ctx, &plan)...)
}
```

**Pitfalls:**
- Forgetting to check IsNull() before ValueString()
- Using Go types directly instead of framework types in models
- Not handling null/unknown properly
- Type mismatches in collections (ElementType)

### Testing for This Phase:

**Manual verification:**
- [ ] Schema section explains all attribute types
- [ ] Nested attributes and blocks both covered
- [ ] Type system section covers conversions
- [ ] Null/unknown handling explained
- [ ] Code examples compile
- [ ] Cross-references work

### Success Criteria:

#### Manual Verification:
- [ ] Schema system section documents all attribute types
- [ ] Nested attributes and blocks explained with examples
- [ ] Attribute modifiers (Required, Optional, Computed, Sensitive) documented
- [ ] Type system section covers all framework types
- [ ] Null and unknown value handling explained
- [ ] Type conversions demonstrated with code
- [ ] At least 6 code examples across both sections
- [ ] Common pitfalls highlighted for both schemas and types
- [ ] No TODOs remain in Phase 3 sections

---

## Phase 4: Validators & Plan Modifiers

### Overview

Document advanced schema capabilities for validation and plan modification. Essential for implementing complex provider logic.

### Content to Create:

#### 4.1 Validators Section
**File**: `docs/index.md:2051-2350`

Create validator documentation:
- **Built-in Validators**: String, int64, list, map, set validators
- **Validator Types**: stringvalidator, int64validator, listvalidator, etc.
- **Common Validators**: LengthBetween, OneOf, AtLeastOneOf, ConflictsWith
- **Custom Validators**: Implementing validator.String, validator.Int64, etc.
- **Multiple Validators**: Combining validators on single attribute

**Code examples:**
1. String validators
2. Numeric validators
3. Collection validators
4. Cross-attribute validators (ConflictsWith, AtLeastOneOf)
5. Custom validator implementation

**Example:**
```go
import (
    "github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
    "github.com/hashicorp/terraform-plugin-framework-validators/int64validator"
    "github.com/hashicorp/terraform-plugin-framework-validators/listvalidator"
    "github.com/hashicorp/terraform-plugin-framework/path"
    "github.com/hashicorp/terraform-plugin-framework/schema/validator"
)

schema.Schema{
    Attributes: map[string]schema.Attribute{
        "name": schema.StringAttribute{
            Required: true,
            Validators: []validator.String{
                stringvalidator.LengthBetween(1, 255),
                stringvalidator.RegexMatches(
                    regexp.MustCompile(`^[a-z0-9-]+$`),
                    "must contain only lowercase letters, numbers, and hyphens",
                ),
            },
        },

        "type": schema.StringAttribute{
            Required: true,
            Validators: []validator.String{
                stringvalidator.OneOf("type_a", "type_b", "type_c"),
            },
        },

        "port": schema.Int64Attribute{
            Optional: true,
            Validators: []validator.Int64{
                int64validator.Between(1, 65535),
            },
        },

        "items": schema.ListAttribute{
            Optional:    true,
            ElementType: types.StringType,
            Validators: []validator.List{
                listvalidator.SizeAtLeast(1),
                listvalidator.SizeAtMost(10),
            },
        },

        // Cross-attribute validation
        "ipv4_address": schema.StringAttribute{
            Optional: true,
            Validators: []validator.String{
                // At least one of ipv4_address or ipv6_address required
                stringvalidator.AtLeastOneOf(
                    path.MatchRoot("ipv6_address"),
                ),
            },
        },

        "ipv6_address": schema.StringAttribute{
            Optional: true,
            Validators: []validator.String{
                // Conflicts with ipv4_only mode
                stringvalidator.ConflictsWith(
                    path.MatchRoot("ipv4_only"),
                ),
            },
        },
    },
}
```

**Custom validator example:**
```go
// Custom validator implementation
type myCustomValidator struct{}

func (v myCustomValidator) Description(ctx context.Context) string {
    return "validates custom business logic"
}

func (v myCustomValidator) MarkdownDescription(ctx context.Context) string {
    return "validates custom business logic"
}

func (v myCustomValidator) ValidateString(ctx context.Context, req validator.StringRequest, resp *validator.StringResponse) {
    if req.ConfigValue.IsNull() || req.ConfigValue.IsUnknown() {
        return
    }

    value := req.ConfigValue.ValueString()

    // Custom validation logic
    if !isValidCustomFormat(value) {
        resp.Diagnostics.Append(validatordiag.InvalidAttributeValueDiagnostic(
            req.Path,
            "Invalid Format",
            fmt.Sprintf("Value %q does not meet custom requirements", value),
        ))
    }
}

// Use in schema
Validators: []validator.String{
    myCustomValidator{},
}
```

**Pitfalls:**
- Validator packages are separate (terraform-plugin-framework-validators)
- Not handling null/unknown in custom validators
- Confusing ConflictsWith vs ExactlyOneOf vs AtLeastOneOf
- Path expressions for cross-attribute validation

#### 4.2 Plan Modifiers Section
**File**: `docs/index.md:2351-2650`

Create plan modifier documentation:
- **What are Plan Modifiers**: Modify planned values before apply
- **Built-in Modifiers**: UseStateForUnknown, RequiresReplace, Default values
- **Modifier Types**: stringplanmodifier, int64planmodifier, listplanmodifier, etc.
- **Custom Plan Modifiers**: Implementing PlanModifier interface
- **Use Cases**: Setting defaults, forcing replacement, computed values

**Code examples:**
1. UseStateForUnknown (common pattern)
2. RequiresReplace
3. Default values
4. Custom plan modifier

**Example:**
```go
import (
    "github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema/int64planmodifier"
)

schema.Schema{
    Attributes: map[string]schema.Attribute{
        "id": schema.StringAttribute{
            Computed: true,
            PlanModifiers: []planmodifier.String{
                // Use state value if available (prevents spurious diffs)
                stringplanmodifier.UseStateForUnknown(),
            },
        },

        "region": schema.StringAttribute{
            Required: true,
            PlanModifiers: []planmodifier.String{
                // Changing region requires replacement
                stringplanmodifier.RequiresReplace(),
            },
        },

        "size": schema.Int64Attribute{
            Optional: true,
            Computed: true,
            PlanModifiers: []planmodifier.Int64{
                // Use previous value if not explicitly changed
                int64planmodifier.UseStateForUnknown(),
            },
        },
    },
}
```

**Custom plan modifier:**
```go
type customPlanModifier struct{}

func (m customPlanModifier) Description(ctx context.Context) string {
    return "custom plan modification logic"
}

func (m customPlanModifier) MarkdownDescription(ctx context.Context) string {
    return "custom plan modification logic"
}

func (m customPlanModifier) PlanModifyString(ctx context.Context, req planmodifier.StringRequest, resp *planmodifier.StringResponse) {
    // Don't modify on resource creation
    if req.State.Raw.IsNull() {
        return
    }

    // Custom logic to modify planned value
    if req.PlanValue.IsUnknown() {
        resp.PlanValue = types.StringValue("custom_default")
    }
}

// Use in schema
PlanModifiers: []planmodifier.String{
    customPlanModifier{},
}
```

**Pitfalls:**
- Not using UseStateForUnknown for computed IDs (causes spurious diffs)
- Overusing RequiresReplace (unnecessary resource churn)
- Plan modifier execution order
- Modifying required values incorrectly

### Testing for This Phase:

**Manual verification:**
- [ ] Validators section covers built-in and custom
- [ ] Plan modifiers section explains common patterns
- [ ] Code examples are complete and correct
- [ ] UseStateForUnknown pattern emphasized (common gotcha)
- [ ] Cross-references to schema section work

### Success Criteria:

#### Manual Verification:
- [ ] Validators section documents all common validator types
- [ ] Cross-attribute validation explained (ConflictsWith, AtLeastOneOf, etc.)
- [ ] Custom validator implementation demonstrated
- [ ] Plan modifiers section covers UseStateForUnknown, RequiresReplace, defaults
- [ ] Custom plan modifier implementation shown
- [ ] At least 5 code examples across both sections
- [ ] Common pitfalls highlighted (especially UseStateForUnknown)
- [ ] No TODOs remain in Phase 4 sections

---

## Phase 5: Functions, Actions & Ephemeral Resources

### Overview

Document advanced provider capabilities: custom functions, actions, and ephemeral resources. These are newer framework features that enable more sophisticated provider behavior.

### Content to Create:

#### 5.1 Functions Section
**File**: `docs/index.md:2651-2900`

Create functions documentation:
- **Provider Functions**: Custom Terraform functions defined by provider
- **Function Interface**: Metadata, Definition, Run methods
- **Function Parameters**: Defining inputs
- **Function Returns**: Defining outputs
- **Use Cases**: Data transformation, validation, computation

**Code example:**
```go
package function

import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/function"
)

type hashFunction struct{}

func NewHashFunction() function.Function {
    return &hashFunction{}
}

func (f *hashFunction) Metadata(_ context.Context, req function.MetadataRequest, resp *function.MetadataResponse) {
    resp.Name = "hash"
}

func (f *hashFunction) Definition(_ context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary:     "Computes hash of input string",
        Description: "Returns SHA256 hash of the input string in hexadecimal format",
        Parameters: []function.Parameter{
            function.StringParameter{
                Name:        "input",
                Description: "String to hash",
            },
        },
        Return: function.StringReturn{},
    }
}

func (f *hashFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string

    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &input))
    if resp.Error != nil {
        return
    }

    // Compute hash
    hash := sha256.Sum256([]byte(input))
    result := hex.EncodeToString(hash[:])

    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
}

// Register in provider
func (p *myProvider) Functions(_ context.Context) []func() function.Function {
    return []func() function.Function{
        NewHashFunction,
    }
}
```

**Usage in Terraform:**
```hcl
output "hashed_value" {
  value = provider::myprovider::hash("hello world")
}
```

**Pitfalls:**
- Functions vs provider-specific data sources (when to use which)
- Error handling in Run method
- Function naming conventions

#### 5.2 Actions Section
**File**: `docs/index.md:2901-3050`

Create actions documentation (brief - newer feature):
- **What are Actions**: Provider-defined operations (not CRUD)
- **Action Interface**: Similar to resources but for operations
- **Use Cases**: Triggering workflows, one-time operations

**Code example outline** (brief, as feature is less common)

**Pitfalls:**
- Actions vs resources (when to use actions)
- Idempotency considerations

#### 5.3 Ephemeral Resources Section
**File**: `docs/index.md:3051-3200`

Create ephemeral resources documentation:
- **What are Ephemeral Resources**: Session-scoped, temporary data
- **Lifecycle**: Open, Read, Close (not Create/Update/Delete)
- **Use Cases**: Temporary credentials, session tokens
- **Ephemeral vs Data Sources**: When to use each

**Code example:**
```go
type sessionResource struct {
    client *http.Client
}

func (r *sessionResource) Metadata(_ context.Context, req ephemeral.MetadataRequest, resp *ephemeral.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_session"
}

func (r *sessionResource) Schema(_ context.Context, _ ephemeral.SchemaRequest, resp *ephemeral.SchemaResponse) {
    resp.Schema = schema.Schema{
        Attributes: map[string]schema.Attribute{
            "token": schema.StringAttribute{
                Computed:  true,
                Sensitive: true,
            },
            "expires_at": schema.StringAttribute{
                Computed: true,
            },
        },
    }
}

func (r *sessionResource) Open(ctx context.Context, req ephemeral.OpenRequest, resp *ephemeral.OpenResponse) {
    // Create temporary session
    // token, expiresAt := r.client.CreateSession(ctx)

    var model sessionModel
    model.Token = types.StringValue(token)
    model.ExpiresAt = types.StringValue(expiresAt)

    resp.Diagnostics.Append(resp.Result.Set(ctx, &model)...)
}

func (r *sessionResource) Close(ctx context.Context, req ephemeral.CloseRequest, resp *ephemeral.CloseResponse) {
    // Cleanup session if needed
}
```

**Pitfalls:**
- Ephemeral resources are session-scoped (don't persist)
- Not available in all Terraform versions

### Testing for This Phase:

**Manual verification:**
- [ ] Functions section explains provider functions clearly
- [ ] Actions section covers basics
- [ ] Ephemeral resources section explains lifecycle
- [ ] Code examples compile
- [ ] Use cases clarified for each capability

### Success Criteria:

#### Manual Verification:
- [ ] Functions section documents Metadata, Definition, Run methods
- [ ] Function parameter and return types explained
- [ ] Function usage in Terraform HCL shown
- [ ] Actions section covers basic concepts
- [ ] Ephemeral resources section explains Open/Close lifecycle
- [ ] At least 3 code examples across all three sections
- [ ] Common pitfalls highlighted
- [ ] No TODOs remain in Phase 5 sections

---

## Phase 6: Testing & Best Practices

### Overview

Document testing approaches and common pitfalls. Critical for agents to build reliable, well-tested providers following best practices.

### Content to Create:

#### 6.1 Testing Patterns Section
**File**: `docs/index.md:3201-3600`

Create comprehensive testing documentation:
- **Unit Testing**: Testing individual functions with testify/require
- **Acceptance Testing**: Full provider integration tests
- **Testing Resource CRUD**: Patterns for testing lifecycle methods
- **Mock Providers**: Using mocks for testing
- **Test Fixtures**: Terraform configuration for tests

**Code examples:**
1. Unit test for resource Create method
2. Acceptance test with terraform-plugin-testing
3. Testing validators
4. Testing plan modifiers

**Unit test example:**
```go
package resource_test

import (
    "context"
    "testing"

    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/stretchr/testify/require"
)

func TestResourceCreate(t *testing.T) {
    r := NewExampleResource()

    // Configure resource
    r.Configure(context.Background(), resource.ConfigureRequest{
        ProviderData: mockClient,
    }, &resource.ConfigureResponse{})

    // Test Create
    resp := &resource.CreateResponse{
        State: tfsdk.State{
            Schema: getTestSchema(),
        },
    }

    r.Create(context.Background(), resource.CreateRequest{
        Plan: testPlanData,
    }, resp)

    require.False(t, resp.Diagnostics.HasError())

    // Verify state was set correctly
    var state myResourceModel
    resp.State.Get(context.Background(), &state)
    require.Equal(t, "expected_value", state.Name.ValueString())
}

func TestResourceCreate_Error(t *testing.T) {
    // Separate test for error case
    r := NewExampleResource()

    // Configure with mock that returns error
    r.Configure(context.Background(), resource.ConfigureRequest{
        ProviderData: mockClientWithError,
    }, &resource.ConfigureResponse{})

    resp := &resource.CreateResponse{}
    r.Create(context.Background(), resource.CreateRequest{
        Plan: invalidPlanData,
    }, resp)

    require.True(t, resp.Diagnostics.HasError())
}
```

**Acceptance test example:**
```go
package provider_test

import (
    "testing"

    "github.com/hashicorp/terraform-plugin-testing/helper/resource"
)

func TestAccExampleResource(t *testing.T) {
    resource.Test(t, resource.TestCase{
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Create and Read testing
            {
                Config: testAccExampleResourceConfig("test_value"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("myprovider_example.test", "name", "test_value"),
                    resource.TestCheckResourceAttrSet("myprovider_example.test", "id"),
                ),
            },
            // Update testing
            {
                Config: testAccExampleResourceConfig("updated_value"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("myprovider_example.test", "name", "updated_value"),
                ),
            },
            // Import testing
            {
                ResourceName:      "myprovider_example.test",
                ImportState:       true,
                ImportStateVerify: true,
            },
        },
    })
}

func testAccExampleResourceConfig(name string) string {
    return fmt.Sprintf(`
resource "myprovider_example" "test" {
  name = %[1]q
}
`, name)
}
```

**Testing patterns to document:**
- Test organization (separate positive/negative tests per go-dev-guidelines)
- Using testify/require for assertions
- Mocking with mockery (reference go-dev-guidelines)
- Acceptance test structure
- Test data fixtures

**Pitfalls:**
- Not testing error cases separately
- Mixing positive and negative tests (anti-pattern per go-dev-guidelines)
- Not using testify/require (should follow go-dev-guidelines)
- Acceptance tests without proper cleanup

#### 6.2 Common Pitfalls & Best Practices Section
**File**: `docs/index.md:3601-3900`

Create comprehensive pitfalls and best practices:
- **Schema Design**: Common mistakes and patterns
- **State Management**: Avoiding state drift issues
- **Error Handling**: Proper diagnostic usage
- **Performance**: Avoiding unnecessary API calls
- **Debugging**: Tools and techniques
- **Go Integration**: Following Go idioms (reference go-dev-guidelines tile)

**Content outline:**
- Always check diagnostics before proceeding
- Use UseStateForUnknown for computed values
- Mark sensitive values as Sensitive
- Separate positive and negative tests (reference go-dev-guidelines)
- Use testify/require for test assertions (reference go-dev-guidelines)
- Handle null and unknown values properly
- RequiresReplace vs ForceNew
- Import state implementation
- Context handling
- Logging best practices

**Best practices:**
- Reference go-dev-guidelines tile for:
  - General Go patterns (TDD, error handling, naming)
  - Testing patterns (testify/require, mockery, test organization)
  - Project structure
- Focus on terraform-plugin-framework-specific patterns here
- Interface design (small, focused)
- State consistency
- API efficiency
- Documentation generation

### Testing for This Phase:

**Manual verification:**
- [ ] Testing section covers unit and acceptance tests
- [ ] Code examples follow go-dev-guidelines patterns
- [ ] Best practices section is comprehensive
- [ ] Go-dev-guidelines tile referenced appropriately
- [ ] Common pitfalls from all previous sections consolidated

### Success Criteria:

#### Manual Verification:
- [ ] Testing section documents both unit and acceptance testing
- [ ] Unit test examples use testify/require (per go-dev-guidelines)
- [ ] Acceptance test examples use terraform-plugin-testing
- [ ] Test organization follows go-dev-guidelines (separate positive/negative)
- [ ] Common pitfalls section consolidates issues from all areas
- [ ] Best practices section includes at least 10 recommendations
- [ ] Go-dev-guidelines tile referenced for general Go patterns
- [ ] Debugging techniques documented
- [ ] At least 4 testing code examples included
- [ ] No TODOs remain in Phase 6 sections

---

## Phase 7: Final Polish & Verification

### Overview

Complete the documentation with final sections, verify all content, ensure consistency, and validate all links and examples.

### Content to Create:

#### 7.1 Additional Resources Section
**File**: `docs/index.md:3901-4000`

Add final sections:
- **External Resources**: Links to official docs, scaffolding, tutorials
- **Package Reference**: Link to pkg.go.dev
- **Community**: HashiCorp forums, GitHub discussions
- **Related Tiles**: Go best practices tile, other relevant tiles

**Content:**
```markdown
## Additional Resources

### Official Documentation
- [Terraform Plugin Framework Docs](https://developer.hashicorp.com/terraform/plugin/framework)
- [Provider Scaffolding Template](https://github.com/hashicorp/terraform-provider-scaffolding-framework)
- [Plugin Documentation Generator](https://github.com/hashicorp/terraform-plugin-docs)
- [Package Reference](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework)

### Tutorials
- [HashiCups Tutorial](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework/providers-plugin-framework-provider)
- [Implement a Provider](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework)

### Related Tiles
- Go Best Practices Tile - General Go development patterns, testing, project structure
- (Reference other relevant tiles as available)

### Community
- [HashiCorp Discuss - Terraform Providers](https://discuss.hashicorp.com/c/terraform-providers)
- [GitHub - terraform-plugin-framework](https://github.com/hashicorp/terraform-plugin-framework)
```

#### 7.2 Comprehensive Review & Verification

**File**: `docs/index.md` (entire file)

Perform thorough review:
1. **Read complete document** - Check flow and consistency
2. **Verify code examples** - Copy/paste into Go file, check compilation
3. **Test internal links** - Verify all TOC links work
4. **Check external links** - Validate all URLs
5. **Consistency check**:
   - Consistent terminology throughout
   - Consistent code style
   - Consistent formatting
   - Section numbering matches TOC
6. **Completeness check**:
   - All 12 sections present
   - No TODO markers remaining
   - All phases completed
   - All success criteria met
7. **Go syntax validation**:
   - All code blocks have ```go syntax
   - All examples are valid Go (no syntax errors)
   - Imports are correct
8. **Markdown validation**:
   - Proper header hierarchy
   - Lists formatted correctly
   - Code blocks closed properly
   - No broken formatting

### Testing for This Phase:

**Manual verification:**
- [ ] Read entire document start to finish
- [ ] Test all 12 section links in TOC
- [ ] Verify all external links (use browser/curl)
- [ ] Copy 10 random code examples into Go files, verify compilation
- [ ] Check for TODO or placeholder text
- [ ] Verify markdown renders correctly
- [ ] Ensure consistent terminology
- [ ] Confirm go-dev-guidelines references are appropriate

### Success Criteria:

#### Automated Verification:
N/A - Documentation task

#### Manual Verification:
- [ ] All 12 major sections complete
- [ ] Table of contents has working links to all sections
- [ ] At least 30 code examples included across all sections
- [ ] All code examples are syntactically valid Go
- [ ] All external links are valid (no 404s)
- [ ] All internal links work correctly
- [ ] No TODO or placeholder text remains
- [ ] Markdown renders correctly in viewer
- [ ] Consistent terminology throughout
- [ ] Go-dev-guidelines tile referenced appropriately (not over-referenced)
- [ ] Common pitfalls highlighted in each section
- [ ] Testing patterns integrated throughout
- [ ] Schema design patterns clearly explained
- [ ] Go-specific framework patterns included
- [ ] File size appropriate (~3000-4000 lines)
- [ ] Ready for agent consumption

---

## Testing Strategy

This is a documentation-only task with no code to test. Testing consists entirely of manual verification.

### Manual Testing Steps:

1. **Readability Test**:
   - Read each section as if you're learning terraform-plugin-framework
   - Verify explanations are clear and concepts flow logically
   - Check that examples support the explanations

2. **Code Validation Test**:
   - Create test Go file with module imports
   - Copy/paste 10-15 random code examples
   - Verify they compile (syntax checking)
   - Note: Examples are snippets, not full programs, but should be valid Go

3. **Link Validation Test**:
   - Click every link in table of contents
   - Verify each link jumps to correct section
   - Test external links (HashiCorp docs, GitHub, pkg.go.dev)

4. **Completeness Test**:
   - Search for "TODO" - should find zero results
   - Verify all 12 sections exist and have content
   - Check that success criteria from each phase are met

5. **Consistency Test**:
   - Check that terminology is consistent (e.g., "data source" vs "datasource")
   - Verify code style is consistent
   - Ensure formatting is consistent (headers, lists, code blocks)

6. **Markdown Rendering Test**:
   - View in markdown preview/renderer
   - Check that formatting displays correctly
   - Verify code blocks have proper syntax highlighting

## Performance Considerations

N/A - Documentation task, no runtime performance considerations.

**Documentation Size**: Target ~3000-4000 lines for comprehensive coverage without being overwhelming. This is appropriate for:
- 12 major sections
- ~30-40 code examples
- Conceptual explanations
- Pitfalls and best practices throughout
- Cross-references and navigation

## Migration Notes

N/A - New documentation creation, no migration needed.

## References

### Research Sources:
- **terraform-plugin-framework package**: https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework
- **HashiCorp Developer Docs**: https://developer.hashicorp.com/terraform/plugin/framework
- **Scaffolding Template**: https://github.com/hashicorp/terraform-provider-scaffolding-framework
- **Plugin Testing**: https://github.com/hashicorp/terraform-plugin-testing
- **Go Development Guidelines**: go-dev-guidelines tile (for testing patterns, Go idioms)

### Key Planning Files:
- Research notes: [terraform-plugin-framework-tile-research.md](terraform-plugin-framework-tile-research.md)
- Context summary: [terraform-plugin-framework-tile-context.md](terraform-plugin-framework-tile-context.md)
- Task checklist: [terraform-plugin-framework-tile-tasks.md](terraform-plugin-framework-tile-tasks.md)

### Repository Files:
- Target file: `docs/index.md` (will be replaced)
- Tile manifest: `tile.json:1-7` (already configured)
- Settings: `.claude/settings.local.json` (permissions configured)
