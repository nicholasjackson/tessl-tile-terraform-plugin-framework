# Terraform Plugin Framework Tile Implementation Plan

**Created**: 2026-02-16
**Last Updated**: 2026-02-16 (Multi-File Structure)
**Type**: Documentation Creation
**Target**: Comprehensive Tessl tile for terraform-plugin-framework

## Overview

Create comprehensive documentation for `github.com/hashicorp/terraform-plugin-framework` (v1.17.0) in a Tessl tile to enable coding agents to build Terraform providers effectively. The documentation will be organized into **multiple files** (12 docs + 5 rules + README) for better context management, covering all major framework capabilities with practical code examples, testing patterns, schema design guidance, common pitfalls, and Go-specific integration patterns.

**Purpose**: Help coding agents understand how to use terraform-plugin-framework to build Terraform providers, covering everything from basic setup to advanced capabilities like functions and ephemeral resources.

**Approach**: Multi-file documentation structure with:
- README.md for tile discovery, testing, and publishing
- 12 documentation files in `docs/` directory (~3300 lines total)
- 5 rules files in `rules/` directory (~750 lines total)
- Updated tile.json with steering configuration
- Each file focused on specific capability area (250-400 lines)

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
- ⚠️ Missing steering configuration for rules

**File**: `docs/index.md:1-24` (Current Template)
- ❌ Template with TODOs - needs to be overview + TOC
- Will become entry point with navigation to other files

**File**: `.claude/settings.local.json:1-7`
- ✅ Permissions configured for docs.tessl.io, developer.hashicorp.com

### What's Missing:

1. **README.md**: No repository overview, installation, testing, or publishing instructions
2. **Multi-file docs**: Only index.md template exists, need 11 more documentation files
3. **Rules/Steering**: No rules directory or best practices files
4. **Content**: All documentation is empty templates
5. **Examples**: No code examples demonstrating framework usage
6. **tile.json steering**: No steering configuration pointing to rules

## Desired End State

A comprehensive multi-file Tessl tile with:

### Repository Structure:
```
/
├── README.md                       # Tile overview, installation, testing, publishing (~150 lines)
├── tile.json                       # Updated with steering configuration
├── docs/
│   ├── index.md                   # Overview + TOC (200-250 lines)
│   ├── quick-start.md             # Getting started (200-250 lines)
│   ├── provider.md                # Provider implementation (300-350 lines)
│   ├── resources.md               # Resources CRUD (350-400 lines)
│   ├── data-sources.md            # Data sources (200-250 lines)
│   ├── schema.md                  # Schema system (350-400 lines)
│   ├── types.md                   # Type system (300-350 lines)
│   ├── validators.md              # Validators (250-300 lines)
│   ├── plan-modifiers.md          # Plan modifiers (250-300 lines)
│   ├── functions.md               # Functions (200-250 lines)
│   ├── advanced.md                # Actions & ephemeral (200-250 lines)
│   └── testing.md                 # Testing patterns (300-350 lines)
└── rules/
    ├── diagnostics.md             # Diagnostics patterns (~100 lines)
    ├── state-management.md        # State consistency (~150 lines)
    ├── schema-design.md           # Schema patterns (~150 lines)
    ├── testing-standards.md       # Testing requirements (~150 lines)
    └── common-pitfalls.md         # Consolidated gotchas (~200 lines)
```

### Content Standards per Doc File:
- **Conceptual explanation**: What it is, why it exists, when to use
- **Key interfaces/types**: Important APIs to implement
- **Code examples**: 20-50 line focused examples (not full providers)
- **Common pitfalls**: What goes wrong, how to avoid/fix
- **Testing patterns**: How to test this capability
- **Cross-references**: Links to related docs and rules

### Content Standards per Rules File:
- **Subjective guidance**: Best practices, when to use patterns
- **Coding standards**: Required patterns (e.g., always check diagnostics)
- **Decision guidance**: When to use which approach
- **Pitfall warnings**: Common mistakes and how to avoid
- **Examples**: Brief code patterns demonstrating best practices

## What We're NOT Doing

Explicitly out of scope:
- ❌ Complete working provider example (code snippets only, reference HashiCorp scaffolding)
- ❌ Migration from terraform-plugin-sdk (framework-only focus)
- ❌ General Go best practices (reference separate Go tile)
- ❌ terraform-plugin-go details (lower level abstraction)
- ❌ Terraform HCL language syntax (focus on provider development)
- ❌ Provider-specific implementation details (e.g., AWS-specific patterns)
- ❌ Automated CI/CD pipeline setup (mention but don't implement)

## Implementation Approach

### Development Philosophy:
- **Research-Driven**: Base content on official HashiCorp docs, pkg.go.dev, and scaffolding template
- **Agent-Friendly**: Focus on "why" and "how", not just "what"
- **Practical**: Every concept has code examples
- **Testing-First**: Testing guidance integrated throughout
- **Pitfall-Aware**: Highlight common gotchas prominently
- **Modular**: Each file standalone but cross-linked

### Content Sources:
1. **Primary**: https://developer.hashicorp.com/terraform/plugin/framework
2. **API Reference**: https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework
3. **Examples**: https://github.com/hashicorp/terraform-provider-scaffolding-framework
4. **Testing**: https://github.com/hashicorp/terraform-plugin-testing
5. **Go Patterns**: Reference go-dev-guidelines tile for TDD, testify/require

### Phase Approach:
- **Phase 1-2**: Foundation and core concepts (README, tile setup, provider basics)
- **Phase 3-5**: Core functionality (resources, schemas, types, validators)
- **Phase 6**: Advanced features (functions, testing)
- **Phase 7**: Rules and steering (best practices)
- **Phase 8**: Testing and publishing (local testing, registry submission)

---

## Phase 1: Foundation & Setup

### Overview
Establish the tile's repository structure, README, and tile.json configuration. Create the foundation that all other phases will build upon.

### Development Approach
1. Create comprehensive README.md following spec-driven-development-tile pattern
2. Update tile.json with steering configuration
3. Create docs/ and rules/ directory structure
4. Set up cross-referencing patterns

### Changes Required

#### File: `README.md` (NEW)
**Purpose**: Tile discovery, installation, usage, testing, and publishing

**Content** (~150 lines):
```markdown
# Terraform Plugin Framework Tile

A comprehensive Tessl tile for building Terraform providers with the terraform-plugin-framework.

**Published versions**: [Tessl Registry](https://tessl.io/registry)
**Source**: [GitHub Repository](https://github.com/nicholasjackson/tessl-tile-terraform-plugin-framework)

## What This Tile Does

This tile provides comprehensive documentation and best practices for building Terraform providers using `github.com/hashicorp/terraform-plugin-framework` (v1.17.0). It helps coding agents:

- Understand provider architecture and implementation patterns
- Build resources with proper CRUD operations and state management
- Design schemas with validators and plan modifiers
- Implement data sources, functions, and ephemeral resources
- Write tests using testify/require and terraform-plugin-testing
- Avoid common pitfalls and follow Go best practices

## Installation

Using Tessl CLI:
```bash
tessl install nicholasjackson/terraform-plugin-framework
```

Using npx:
```bash
npx @tessl/cli install nicholasjackson/terraform-plugin-framework
```

## Usage

Include "use terraform-plugin-framework" in your prompts when developing Terraform providers:

```
Create a new Terraform provider for managing XYZ resources. Use terraform-plugin-framework.
```

The tile provides context about:
- Provider implementation patterns
- Resource and data source development
- Schema design and type system
- Testing strategies
- Common gotchas and best practices

## What's in This Tile

### Documentation (`docs/`)

| File | Description |
|------|-------------|
| `index.md` | Overview and navigation table of contents |
| `quick-start.md` | Getting started guide and when to use the framework |
| `provider.md` | Provider interface, configuration, server setup |
| `resources.md` | Resource CRUD operations, state management, import |
| `data-sources.md` | Data source implementation patterns |
| `schema.md` | Schema system, attributes, blocks, nesting |
| `types.md` | Type system, conversions, null/unknown handling |
| `validators.md` | Built-in and custom validators |
| `plan-modifiers.md` | Plan modifiers, UseStateForUnknown patterns |
| `functions.md` | Provider functions and parameters |
| `advanced.md` | Actions and ephemeral resources |
| `testing.md` | Unit and acceptance testing patterns |

### Rules (`rules/`)

Best practices and steering guidance automatically loaded by agents:

| File | Description |
|------|-------------|
| `diagnostics.md` | Always check diagnostics before proceeding |
| `state-management.md` | State consistency patterns and UseStateForUnknown |
| `schema-design.md` | Schema design patterns and attribute modifiers |
| `testing-standards.md` | testify/require requirements and test organization |
| `common-pitfalls.md` | Consolidated gotchas from all framework areas |

## Why This Tile

Building Terraform providers with terraform-plugin-framework requires understanding:
- Complex state management and lifecycle operations
- Schema design with nested attributes and blocks
- Type system conversions and null/unknown values
- Plan modifiers and when to use them (critical UseStateForUnknown pattern)
- Testing patterns for both unit and acceptance tests
- Common pitfalls that lead to runtime panics or incorrect behavior

This tile consolidates this knowledge in an agent-friendly format, reducing trial-and-error and helping agents build correct, well-tested providers following best practices.

## How It Works

This is a **documentation tile** with **steering rules**:

**Documentation** (`docs/`): Technical reference for framework capabilities, organized by topic (provider, resources, schemas, etc.). Each file explains concepts, shows code examples, and highlights common pitfalls.

**Rules** (`rules/`): Best practices and subjective guidance that Tessl consolidates into `.tessl/RULES.md`. These steer agent behavior automatically (e.g., "always check diagnostics", "use UseStateForUnknown for computed attributes").

When you install this tile, agents (Claude Code, Cursor, etc.) gain context about terraform-plugin-framework without requiring you to explain basic concepts.

## Testing This Tile Locally

Before publishing, test the tile locally:

1. **Install locally**:
   ```bash
   cd /path/to/tessl-tile-terraform-plugin-framework
   tessl install .
   ```

2. **Create test provider**:
   Create a sample Terraform provider project to validate tile effectiveness:
   ```bash
   mkdir test-provider
   cd test-provider
   go mod init github.com/example/terraform-provider-test
   ```

3. **Test with agent**:
   Use Claude Code or Cursor to build a simple resource:
   ```
   Create a simple Terraform resource for managing a "Pet" with name and species attributes.
   Use terraform-plugin-framework.
   ```

4. **Verify**:
   - Agent references tile documentation correctly
   - Code follows patterns from docs
   - Agent applies rules (checks diagnostics, uses UseStateForUnknown, etc.)
   - Generated code compiles and passes `go vet`

5. **Iterate**:
   - Update tile documentation based on findings
   - Test again until tile provides clear, accurate guidance

## Publishing to Tessl Registry

### Option 1: GitHub Action (Recommended)

Use the Tessl publish action for automated publishing:

1. Create `.github/workflows/publish.yml`:
   ```yaml
   name: Publish Tile
   on:
     push:
       tags:
         - 'v*'
   jobs:
     publish:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: tesslio/publish@v1
           with:
             tessl_token: ${{ secrets.TESSL_TOKEN }}
   ```

2. Tag and push:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

### Option 2: Manual Submission

1. Submit via Tessl registry:
   - Visit https://tessl.io/registry/skills/submit
   - Provide repository URL and version
   - Wait for Tessl evaluation

2. Verify publication:
   - Check tile appears in registry
   - Test installation from registry in fresh environment

### Version Management

Follow semantic versioning in `tile.json`:
- **Patch** (0.1.x): Bug fixes, typo corrections, clarifications
- **Minor** (0.x.0): New documentation sections, additional examples
- **Major** (x.0.0): Breaking changes to tile structure or major rewrites

## Links

- [Tessl Registry](https://tessl.io/registry)
- [Tessl Discord](https://discord.gg/tessl)
- [terraform-plugin-framework Documentation](https://developer.hashicorp.com/terraform/plugin/framework)
- [terraform-plugin-framework on pkg.go.dev](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework)
- [HashiCorp Scaffolding Template](https://github.com/hashicorp/terraform-provider-scaffolding-framework)

## License

MIT License - See LICENSE file for details.
```

**Reasoning**:
- Follows spec-driven-development-tile README pattern
- Adds testing section for local validation before publishing
- Adds publishing section with both GitHub Action and manual options
- Includes "What's in This Tile" table for quick discovery
- Explains both docs and rules components
- Provides clear usage examples

#### File: `tile.json:1-7` (UPDATE)
**Current**:
```json
{
  "name": "nicholasjackson/terraform-plugin-framework",
  "version": "0.1.0",
  "summary": "terraform-plugin-framework is a module for building Terraform providers...",
  "describes": "pkg:golang/github.com/hashicorp/terraform-plugin-framework",
  "docs": "docs/index.md"
}
```

**Updated**:
```json
{
  "name": "nicholasjackson/terraform-plugin-framework",
  "version": "0.1.0",
  "summary": "Comprehensive documentation and best practices for building Terraform providers with terraform-plugin-framework (v1.17.0). Covers providers, resources, schemas, types, validators, testing, and common pitfalls.",
  "describes": "pkg:golang/github.com/hashicorp/terraform-plugin-framework@v1.17.0",
  "docs": "docs/index.md",
  "steering": {
    "rules": [
      "rules/diagnostics.md",
      "rules/state-management.md",
      "rules/schema-design.md",
      "rules/testing-standards.md",
      "rules/common-pitfalls.md"
    ]
  }
}
```

**Changes**:
- Enhanced summary with version and coverage details
- Added version specifier to "describes" field
- Added "steering" object with rules array
- Rules will be consolidated into `.tessl/RULES.md` by Tessl

**Reasoning**:
- Steering configuration enables automatic loading of best practices
- Version specification helps agents know which framework version docs cover
- Clearer summary improves tile discovery in registry

#### Directory Structure Creation
Create empty directories that will be populated in later phases:
```bash
mkdir -p docs
mkdir -p rules
```

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist
[ -f README.md ] && echo "✓ README.md exists"
[ -f tile.json ] && echo "✓ tile.json exists"
[ -d docs ] && echo "✓ docs/ directory exists"
[ -d rules ] && echo "✓ rules/ directory exists"

# Validate tile.json syntax
cat tile.json | jq . > /dev/null && echo "✓ tile.json valid JSON"
```

**Manual Verification**:
- README.md renders correctly in markdown viewer
- All sections are present and well-formatted
- Links are valid (no 404s)
- tile.json follows Tessl schema

### Success Criteria

#### Automated:
- [ ] README.md file exists and is ~150 lines
- [ ] tile.json contains steering configuration with 5 rules
- [ ] tile.json is valid JSON
- [ ] docs/ directory exists
- [ ] rules/ directory exists

#### Manual:
- [ ] README follows spec-driven-development-tile pattern
- [ ] Testing section provides clear local testing workflow
- [ ] Publishing section covers both GitHub Action and manual options
- [ ] "What's in This Tile" table lists all 12 docs + 5 rules
- [ ] All README links are valid

---

## Phase 2: Core Documentation Files

### Overview
Create the entry point documentation (index.md), getting started guide (quick-start.md), and provider implementation guide (provider.md). These form the foundation that other documentation builds upon.

### Development Approach
1. Write docs/index.md as overview + comprehensive TOC with links
2. Write docs/quick-start.md covering installation and first provider
3. Write docs/provider.md covering Provider interface and configuration
4. Ensure consistent cross-linking between files
5. Base content on HashiCorp official docs and scaffolding template

### Changes Required

#### File: `docs/index.md` (REPLACE)
**Purpose**: Overview and navigation hub for all documentation

**Content** (~200-250 lines):
```markdown
# Terraform Plugin Framework Guide

Comprehensive documentation for building Terraform providers with `github.com/hashicorp/terraform-plugin-framework` (v1.17.0).

## What is terraform-plugin-framework?

terraform-plugin-framework is the **recommended** Go SDK for building Terraform providers. It provides a structured, type-safe approach to implementing providers, resources, data sources, functions, and other Terraform capabilities.

**Key Benefits**:
- **Type Safety**: Strong typing throughout with compile-time checks
- **Modern Architecture**: Protocol version 6 support (latest Terraform protocol)
- **Flexible Schema System**: Rich attribute types, nested structures, validation
- **Testing Support**: Integration with terraform-plugin-testing for acceptance tests
- **Extensibility**: Custom types, validators, plan modifiers

**When to Use**:
- Building new Terraform providers (recommended)
- Need for complex nested schemas
- Requirement for custom types or validation logic
- Protocol version 6 features needed

**When NOT to Use**:
- Maintaining existing terraform-plugin-sdk providers (migration effort required)
- Very simple providers (framework may be overkill, but still recommended)

## Version Compatibility

- **Framework**: v1.17.0 (covered by this documentation)
- **Go**: 1.24+ required
- **Terraform**: 1.0+ (protocol v6 support)
- **Testing**: terraform-plugin-testing v1.0+

## Architecture Overview

```
Provider (metadata, config, resources, data sources, functions)
├── Resources (CRUD operations, state management)
│   └── Schema (attributes, validators, plan modifiers)
├── Data Sources (read operations)
│   └── Schema (attributes, validators)
├── Functions (custom Terraform functions)
└── Actions & Ephemeral Resources (session-scoped operations)
```

**Protocol Flow**:
1. Terraform CLI starts provider as plugin subprocess
2. Provider registers capabilities (resources, data sources, functions)
3. Terraform calls provider methods via gRPC protocol
4. Provider performs operations and returns results with diagnostics

## Documentation Structure

This documentation is organized by framework capability:

### Getting Started
- [Quick Start](quick-start.md) - Installation, first provider, when to use

### Core Implementation
- [Provider](provider.md) - Provider interface, configuration, server setup
- [Resources](resources.md) - Resource CRUD, state management, import, lifecycle
- [Data Sources](data-sources.md) - Data source implementation, read patterns

### Schema & Types
- [Schema System](schema.md) - Attributes, blocks, nesting, computed vs required
- [Type System](types.md) - Framework types, conversions, null/unknown handling
- [Validators](validators.md) - Built-in validators, custom validators, cross-attribute
- [Plan Modifiers](plan-modifiers.md) - UseStateForUnknown, RequiresReplace, custom

### Advanced Features
- [Functions](functions.md) - Provider functions, parameters, returns, HCL usage
- [Advanced](advanced.md) - Actions and ephemeral resources

### Testing & Best Practices
- [Testing](testing.md) - Unit tests (testify/require), acceptance tests, patterns

### Rules & Steering
The tile includes best practices rules (automatically loaded by agents):
- **Diagnostics**: Always check diagnostics before proceeding
- **State Management**: State consistency, UseStateForUnknown patterns
- **Schema Design**: Schema design patterns, attribute modifiers
- **Testing Standards**: testify/require requirements, test organization
- **Common Pitfalls**: Consolidated gotchas from all areas

## Common Patterns

### Resource Implementation Pattern
```go
// 1. Define resource type implementing resource.Resource
type PetResource struct {
    client *api.Client
}

// 2. Implement required methods
func (r *PetResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}

func (r *PetResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    // Define schema with attributes
}

func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // Implement create logic
    // ALWAYS check resp.Diagnostics.HasError()
}

// Similar for Read, Update, Delete
```

**Key Points**:
- Always check `resp.Diagnostics.HasError()` after operations
- Use framework types (`types.String`, `types.Int64`, etc.) for attributes
- State management via `req.State.Get()` and `resp.State.Set()`
- Return early if diagnostics has errors

### Schema Definition Pattern
```go
schema.Schema{
    Attributes: map[string]schema.Attribute{
        "id": schema.StringAttribute{
            Computed: true,
            PlanModifiers: []planmodifier.String{
                stringplanmodifier.UseStateForUnknown(),
            },
        },
        "name": schema.StringAttribute{
            Required: true,
            Validators: []validator.String{
                stringvalidator.LengthAtLeast(1),
            },
        },
    },
}
```

**Key Points**:
- `Required`, `Optional`, `Computed` determine attribute behavior
- Use `UseStateForUnknown()` for computed attributes in Create
- Add validators to enforce constraints
- Use plan modifiers to control planning behavior

## Common Pitfalls

⚠️ **Not Checking Diagnostics**: Always check `resp.Diagnostics.HasError()` before proceeding. Continuing after errors leads to panics.

⚠️ **Missing UseStateForUnknown**: Computed attributes without `UseStateForUnknown()` in Create operations show as "known after apply" unnecessarily, causing unnecessary replaces.

⚠️ **Type Conversion Errors**: Framework types (`types.String`) are not Go primitives. Use `.ValueString()`, `.ValueInt64()`, etc. for conversion. Check `.IsNull()` and `.IsUnknown()` first.

⚠️ **State Management**: Forgetting to call `resp.State.Set()` at the end of CRUD operations means state isn't saved, causing Terraform to think resource doesn't exist.

⚠️ **Null vs Unknown**: Null = explicitly no value (set to `null`). Unknown = value not yet known (depends on another resource). Handle both cases.

See [Rules](../rules/) directory for comprehensive pitfalls and best practices.

## External Resources

### Official Documentation
- [HashiCorp Developer Docs](https://developer.hashicorp.com/terraform/plugin/framework)
- [Package Reference](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework)
- [Scaffolding Template](https://github.com/hashicorp/terraform-provider-scaffolding-framework)
- [Plugin Testing](https://github.com/hashicorp/terraform-plugin-testing)

### Community
- [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-providers/)
- [Terraform Provider Development Program](https://www.hashicorp.com/partners/become-a-partner)

### Related Tiles
- **Go Best Practices** - General Go patterns (TDD, testify/require, mockery)
- Reference for general Go idioms, this tile focuses on terraform-plugin-framework specifics

## Quick Links

| Topic | Documentation |
|-------|---------------|
| First Provider | [Quick Start](quick-start.md) |
| Provider Setup | [Provider](provider.md) |
| Resource CRUD | [Resources](resources.md) |
| Schema Design | [Schema System](schema.md) |
| Type System | [Type System](types.md) |
| Validation | [Validators](validators.md) |
| Plan Modifiers | [Plan Modifiers](plan-modifiers.md) |
| Testing | [Testing](testing.md) |

## Navigation

- **Next**: [Quick Start](quick-start.md) - Get started building your first provider
- **Up**: [README](../README.md) - Tile overview and installation

---

*This documentation covers terraform-plugin-framework v1.17.0. For the latest version, see [pkg.go.dev](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework).*
```

**Reasoning**:
- Serves as navigation hub with TOC linking to all other docs
- Provides quick overview of framework purpose and benefits
- Shows common patterns with code examples
- Highlights critical pitfalls upfront
- Links to external resources and related tiles
- Quick links table for common topics

#### File: `docs/quick-start.md` (NEW)
**Purpose**: Getting started guide covering installation and first provider

**Content** (~200-250 lines):
- Installation steps (go get, go mod init)
- Minimal provider example (Provider interface only)
- Directory structure for provider projects
- Running provider locally with Terraform
- When to use framework vs SDK
- Next steps and where to go for more detail

**Cross-references**:
- Link to provider.md for full Provider implementation
- Link to resources.md for adding resources
- Link to testing.md for adding tests

#### File: `docs/provider.md` (NEW)
**Purpose**: Provider interface implementation, configuration, server setup

**Content** (~300-350 lines):
- provider.Provider interface and all methods
- Provider configuration (Metadata, Schema, Configure)
- providerserver.Serve() for starting provider
- Provider metadata and version management
- Provider-level clients and shared configuration
- Code example showing complete Provider implementation
- Testing provider configuration
- Common pitfalls (not exporting Resources/DataSources, server setup errors)

**Cross-references**:
- Link to resources.md for implementing resources
- Link to data-sources.md for implementing data sources
- Link to schema.md for provider configuration schema

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist and have content
[ -s docs/index.md ] && echo "✓ docs/index.md has content"
[ -s docs/quick-start.md ] && echo "✓ docs/quick-start.md has content"
[ -s docs/provider.md ] && echo "✓ docs/provider.md has content"

# Verify line counts are in expected range
wc -l docs/index.md  # Should be 200-250
wc -l docs/quick-start.md  # Should be 200-250
wc -l docs/provider.md  # Should be 300-350

# Check for key sections (example for index.md)
grep -q "## What is terraform-plugin-framework?" docs/index.md && echo "✓ Overview section present"
grep -q "## Documentation Structure" docs/index.md && echo "✓ TOC section present"
grep -q "## Common Pitfalls" docs/index.md && echo "✓ Pitfalls section present"
```

**Manual Verification**:
- All markdown renders correctly
- Internal links work (click each link in TOC)
- External links are valid (no 404s)
- Code examples are syntactically valid Go
- Cross-references between files work

### Success Criteria

#### Automated:
- [ ] docs/index.md exists and is 200-250 lines
- [ ] docs/quick-start.md exists and is 200-250 lines
- [ ] docs/provider.md exists and is 300-350 lines
- [ ] All files contain required sections (grep checks pass)
- [ ] All code blocks use ```go syntax highlighting

#### Manual:
- [ ] index.md provides clear overview and navigation
- [ ] index.md TOC links to all 12 documentation files
- [ ] quick-start.md enables creating first provider
- [ ] provider.md covers all Provider interface methods
- [ ] All code examples are valid Go syntax
- [ ] Cross-references between files work
- [ ] Common pitfalls are highlighted prominently

---

## Phase 3: Resource & Data Source Documentation

### Overview
Document resource CRUD operations and data source implementation patterns. These are the core capabilities providers implement.

### Development Approach
1. Write docs/resources.md covering full resource lifecycle
2. Write docs/data-sources.md covering data source patterns
3. Include extensive code examples for CRUD operations
4. Cover state management, ImportState, lifecycle customization
5. Highlight common resource pitfalls (state not saved, diagnostics not checked)

### Changes Required

#### File: `docs/resources.md` (NEW)
**Purpose**: Resource CRUD operations, state management, import, lifecycle

**Content** (~350-400 lines):
```markdown
# Resources

Resources are the primary way providers manage infrastructure in Terraform. A resource implements Create, Read, Update, and Delete (CRUD) operations plus optional capabilities like ImportState.

## Overview

**Resources**:
- Manage infrastructure lifecycle (create, read, update, delete)
- Store state between Terraform runs
- Support import of existing infrastructure
- Define schema with attributes and validation
- Return diagnostics for errors and warnings

**Key Interfaces**:
- `resource.Resource` (required) - Core CRUD operations
- `resource.ResourceWithConfigure` (optional) - Receive provider configuration
- `resource.ResourceWithImportState` (optional) - Support `terraform import`
- `resource.ResourceWithModifyPlan` (optional) - Custom plan modification
- `resource.ResourceWithValidateConfig` (optional) - Configuration validation

## Resource Interface

```go
type Resource interface {
    // Metadata returns the resource type name
    Metadata(context.Context, MetadataRequest, *MetadataResponse)

    // Schema returns the resource schema
    Schema(context.Context, SchemaRequest, *SchemaResponse)

    // Create creates a new resource
    Create(context.Context, CreateRequest, *CreateResponse)

    // Read refreshes the Terraform state
    Read(context.Context, ReadRequest, *ReadResponse)

    // Update updates an existing resource
    Update(context.Context, UpdateRequest, *UpdateResponse)

    // Delete deletes the resource
    Delete(context.Context, DeleteRequest, *DeleteResponse)
}
```

## Minimal Resource Example

```go
package provider

import (
    "context"
    "fmt"

    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure PetResource implements resource.Resource
var _ resource.Resource = &PetResource{}

// PetResource defines the resource implementation
type PetResource struct {
    client *api.Client
}

// PetResourceModel describes the resource data model
type PetResourceModel struct {
    ID      types.String `tfsdk:"id"`
    Name    types.String `tfsdk:"name"`
    Species types.String `tfsdk:"species"`
    Age     types.Int64  `tfsdk:"age"`
}

func (r *PetResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_pet"
}

func (r *PetResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        MarkdownDescription: "Pet resource manages pets in the pet store API.",

        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Computed:            true,
                MarkdownDescription: "Unique identifier for the pet.",
            },
            "name": schema.StringAttribute{
                Required:            true,
                MarkdownDescription: "Name of the pet.",
            },
            "species": schema.StringAttribute{
                Required:            true,
                MarkdownDescription: "Species (dog, cat, etc.).",
            },
            "age": schema.Int64Attribute{
                Optional:            true,
                MarkdownDescription: "Age of the pet in years.",
            },
        },
    }
}
```

## Create Operation

```go
func (r *PetResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    // 1. Retrieve values from plan
    var plan PetResourceModel
    diags := req.Plan.Get(ctx, &plan)
    resp.Diagnostics.Append(diags...)
    if resp.Diagnostics.HasError() {
        return  // CRITICAL: Return early if errors
    }

    // 2. Create API request from plan values
    createReq := api.CreatePetRequest{
        Name:    plan.Name.ValueString(),
        Species: plan.Species.ValueString(),
    }
    if !plan.Age.IsNull() {
        age := plan.Age.ValueInt64()
        createReq.Age = &age
    }

    // 3. Call API to create resource
    pet, err := r.client.CreatePet(ctx, createReq)
    if err != nil {
        resp.Diagnostics.AddError(
            "Error creating pet",
            fmt.Sprintf("Could not create pet: %s", err),
        )
        return
    }

    // 4. Map response to state model
    plan.ID = types.StringValue(pet.ID)
    plan.Name = types.StringValue(pet.Name)
    plan.Species = types.StringValue(pet.Species)
    if pet.Age != nil {
        plan.Age = types.Int64Value(*pet.Age)
    } else {
        plan.Age = types.Int64Null()
    }

    // 5. Set state (CRITICAL: must call this)
    diags = resp.State.Set(ctx, plan)
    resp.Diagnostics.Append(diags...)
}
```

**Key Points**:
- **Always check `resp.Diagnostics.HasError()`** after `req.Plan.Get()` and return early
- **Convert framework types** using `.ValueString()`, `.ValueInt64()`, etc.
- **Handle null values** with `.IsNull()` checks before conversion
- **Set state** with `resp.State.Set()` at the end - if you forget, Terraform thinks resource wasn't created
- **Return diagnostics** for errors using `resp.Diagnostics.AddError()`

## Read Operation

```go
func (r *PetResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    // 1. Get current state
    var state PetResourceModel
    diags := req.State.Get(ctx, &state)
    resp.Diagnostics.Append(diags...)
    if resp.Diagnostics.HasError() {
        return
    }

    // 2. Call API to get current resource state
    pet, err := r.client.GetPet(ctx, state.ID.ValueString())
    if err != nil {
        if api.IsNotFound(err) {
            // Resource no longer exists - remove from state
            resp.State.RemoveResource(ctx)
            return
        }
        resp.Diagnostics.AddError(
            "Error reading pet",
            fmt.Sprintf("Could not read pet %s: %s", state.ID.ValueString(), err),
        )
        return
    }

    // 3. Update state with API response
    state.Name = types.StringValue(pet.Name)
    state.Species = types.StringValue(pet.Species)
    if pet.Age != nil {
        state.Age = types.Int64Value(*pet.Age)
    } else {
        state.Age = types.Int64Null()
    }

    // 4. Set refreshed state
    diags = resp.State.Set(ctx, &state)
    resp.Diagnostics.Append(diags...)
}
```

**Key Points**:
- **Check if resource exists** - if not found, call `resp.State.RemoveResource(ctx)` to remove from state
- **Refresh all attributes** from API response (don't assume state is correct)
- **Handle API errors** appropriately (transient vs permanent failures)
- **Set state** even if nothing changed (Terraform needs confirmation)

## Update Operation

```go
func (r *PetResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    // 1. Get plan and current state
    var plan, state PetResourceModel

    diagsPlan := req.Plan.Get(ctx, &plan)
    resp.Diagnostics.Append(diagsPlan...)

    diagsState := req.State.Get(ctx, &state)
    resp.Diagnostics.Append(diagsState...)

    if resp.Diagnostics.HasError() {
        return
    }

    // 2. Create update request with changes
    updateReq := api.UpdatePetRequest{
        ID: state.ID.ValueString(),
    }

    // Only send changed fields (optional optimization)
    if !plan.Name.Equal(state.Name) {
        updateReq.Name = plan.Name.ValueStringPointer()
    }
    if !plan.Species.Equal(state.Species) {
        updateReq.Species = plan.Species.ValueStringPointer()
    }
    if !plan.Age.Equal(state.Age) {
        if !plan.Age.IsNull() {
            age := plan.Age.ValueInt64()
            updateReq.Age = &age
        } else {
            updateReq.Age = nil  // Explicitly unset
        }
    }

    // 3. Call API to update
    pet, err := r.client.UpdatePet(ctx, updateReq)
    if err != nil {
        resp.Diagnostics.AddError(
            "Error updating pet",
            fmt.Sprintf("Could not update pet %s: %s", state.ID.ValueString(), err),
        )
        return
    }

    // 4. Update state with API response
    plan.Name = types.StringValue(pet.Name)
    plan.Species = types.StringValue(pet.Species)
    if pet.Age != nil {
        plan.Age = types.Int64Value(*pet.Age)
    } else {
        plan.Age = types.Int64Null()
    }

    // 5. Set updated state
    diags := resp.State.Set(ctx, plan)
    resp.Diagnostics.Append(diags...)
}
```

**Key Points**:
- **Get both plan and state** - plan has desired values, state has current values
- **Compare changes** using `.Equal()` method (optional optimization)
- **Update via API** with new values
- **Set state** from API response (not from plan - API is source of truth)

## Delete Operation

```go
func (r *PetResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    // 1. Get current state
    var state PetResourceModel
    diags := req.State.Get(ctx, &state)
    resp.Diagnostics.Append(diags...)
    if resp.Diagnostics.HasError() {
        return
    }

    // 2. Call API to delete
    err := r.client.DeletePet(ctx, state.ID.ValueString())
    if err != nil {
        if api.IsNotFound(err) {
            // Already deleted - no error
            return
        }
        resp.Diagnostics.AddError(
            "Error deleting pet",
            fmt.Sprintf("Could not delete pet %s: %s", state.ID.ValueString(), err),
        )
        return
    }

    // 3. State is automatically removed if no errors
}
```

**Key Points**:
- **Handle already-deleted** resources gracefully (no error if resource doesn't exist)
- **State is auto-removed** on success (don't need to call RemoveResource explicitly)
- **Return error** if delete fails (prevents Terraform from removing state prematurely)

## State Management

### Setting State
```go
// In any CRUD operation:
resp.State.Set(ctx, &model)
```

**CRITICAL**: You **MUST** call `resp.State.Set()` in Create, Read, and Update. Forgetting this makes Terraform think the resource doesn't exist or has no attributes.

### Removing State
```go
// In Read when resource no longer exists:
resp.State.RemoveResource(ctx)
```

### Partial State
If an operation partially succeeds, set state for what succeeded before returning error:
```go
// Created resource but failed to add tags
resp.State.Set(ctx, &partialModel)  // Save what we have
resp.Diagnostics.AddError("Partial failure", "Created resource but failed to add tags")
```

This prevents Terraform from thinking resource doesn't exist and trying to recreate it.

## ImportState

Enable `terraform import` to bring existing resources under Terraform management:

```go
// Implement resource.ResourceWithImportState
var _ resource.ResourceWithImportState = &PetResource{}

func (r *PetResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // Import using ID from command line
    // terraform import myprovider_pet.example pet-123

    // Set ID in state
    resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)

    // Terraform will call Read() next to populate rest of state
}
```

**For complex imports** (multiple values needed):
```go
func (r *PetResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // Import format: "region:pet-id"
    // terraform import myprovider_pet.example us-west-2:pet-123

    parts := strings.Split(req.ID, ":")
    if len(parts) != 2 {
        resp.Diagnostics.AddError(
            "Invalid import ID",
            "Expected format: region:pet-id",
        )
        return
    }

    resp.Diagnostics.Append(resp.State.SetAttribute(ctx, path.Root("region"), parts[0])...)
    resp.Diagnostics.Append(resp.State.SetAttribute(ctx, path.Root("id"), parts[1])...)
}
```

## Resource Configuration

Receive provider configuration in resource:

```go
var _ resource.ResourceWithConfigure = &PetResource{}

func (r *PetResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
    // Prevent panic if provider not configured
    if req.ProviderData == nil {
        return
    }

    client, ok := req.ProviderData.(*api.Client)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Resource Configure Type",
            fmt.Sprintf("Expected *api.Client, got: %T", req.ProviderData),
        )
        return
    }

    r.client = client
}
```

**Provider must set ProviderData** in its Configure method:
```go
// In provider Configure():
resp.ResourceData = client
resp.DataSourceData = client
```

## Common Pitfalls

⚠️ **Not Setting State**: Forgetting `resp.State.Set()` in CRUD operations makes Terraform think resource doesn't exist or has no attributes. **Always set state**.

⚠️ **Not Checking Diagnostics**: Continuing after `req.Plan.Get()` or `req.State.Get()` errors leads to nil pointer panics. **Always check `resp.Diagnostics.HasError()` and return early**.

⚠️ **Type Conversion**: Framework types are not Go primitives. Use `.ValueString()`, `.ValueInt64()`, etc. Check `.IsNull()` and `.IsUnknown()` before converting.

⚠️ **Read Not Handling 404**: If resource is deleted outside Terraform, Read must call `resp.State.RemoveResource(ctx)`, otherwise Terraform keeps stale state.

⚠️ **Using Plan Values as Source of Truth**: In Update, use API response to set state, not plan values. API is source of truth (may normalize or add defaults).

⚠️ **Delete Errors on Already-Deleted**: If resource is already deleted, don't return error. This is a success case (idempotent delete).

⚠️ **Missing Import**: Forgetting to implement ImportState means users can't bring existing resources under management.

See [rules/state-management.md](../rules/state-management.md) for more patterns and [rules/common-pitfalls.md](../rules/common-pitfalls.md) for comprehensive gotchas.

## Testing Resources

See [Testing](testing.md) for comprehensive testing patterns. Quick example:

```go
func TestPetResource_Create(t *testing.T) {
    resource := &PetResource{
        client: mockClient,
    }

    // Test Create operation
    req := resource.CreateRequest{/* ... */}
    resp := &resource.CreateResponse{/* ... */}

    resource.Create(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
    // Assert state was set correctly
}
```

## Cross-References

- [Schema System](schema.md) - Defining resource schemas with attributes and blocks
- [Type System](types.md) - Framework types and conversions
- [Plan Modifiers](plan-modifiers.md) - UseStateForUnknown and other modifiers
- [Testing](testing.md) - Unit and acceptance testing for resources
- [Data Sources](data-sources.md) - Similar but read-only

## External Resources

- [HashiCorp: Resources](https://developer.hashicorp.com/terraform/plugin/framework/resources)
- [resource package](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/resource)
- [Scaffolding Template Resources](https://github.com/hashicorp/terraform-provider-scaffolding-framework/tree/main/internal/provider)
```

**Reasoning**:
- Comprehensive coverage of resource lifecycle (CRUD + Import)
- Extensive code examples showing real implementation patterns
- Emphasizes critical concepts (state management, diagnostics checking)
- Highlights common pitfalls with warnings
- Cross-references to related documentation

#### File: `docs/data-sources.md` (NEW)
**Purpose**: Data source implementation patterns (read-only resources)

**Content** (~200-250 lines):
- datasource.DataSource interface and methods
- Key differences from resources (read-only, no Create/Update/Delete)
- Schema for data sources (all attributes computed or optional)
- Read operation implementation
- Configuration vs computed attributes
- Testing data sources
- Common pitfalls (treating like resources, not handling missing data)

**Cross-references**:
- Link to resources.md for comparison with resources
- Link to schema.md for data source schema patterns
- Link to testing.md for testing data sources

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist and have content
[ -s docs/resources.md ] && echo "✓ docs/resources.md has content"
[ -s docs/data-sources.md ] && echo "✓ docs/data-sources.md has content"

# Verify line counts
wc -l docs/resources.md  # Should be 350-400
wc -l docs/data-sources.md  # Should be 200-250

# Check for key sections
grep -q "## Create Operation" docs/resources.md && echo "✓ CRUD sections present"
grep -q "## State Management" docs/resources.md && echo "✓ State management section present"
grep -q "## ImportState" docs/resources.md && echo "✓ Import section present"
```

**Manual Verification**:
- All code examples compile (copy/paste test)
- CRUD examples are clear and complete
- State management patterns are explained
- Pitfalls are highlighted prominently
- Cross-references work

### Success Criteria

#### Automated:
- [ ] docs/resources.md exists and is 350-400 lines
- [ ] docs/data-sources.md exists and is 200-250 lines
- [ ] All CRUD operations documented with examples
- [ ] State management section present
- [ ] ImportState section present

#### Manual:
- [ ] Resource CRUD patterns are clear and actionable
- [ ] State management is thoroughly explained
- [ ] Import patterns cover simple and complex cases
- [ ] Data source differences from resources are clear
- [ ] Common pitfalls are highlighted with ⚠️ warnings
- [ ] All code examples are valid Go

---

## Phase 4: Schema & Type System Documentation

### Overview
Document the schema system (attributes, blocks, nesting) and type system (framework types, conversions, null/unknown handling). These are fundamental to defining resource/data source structure.

### Development Approach
1. Write docs/schema.md covering attribute types, blocks, nesting
2. Write docs/types.md covering framework types and conversions
3. Include examples of complex nested structures
4. Explain null vs unknown values thoroughly
5. Cover common schema design patterns

### Changes Required

#### File: `docs/schema.md` (NEW)
**Purpose**: Schema system, attributes, blocks, nesting, computed vs required

**Content** (~350-400 lines):
- schema.Schema structure and purpose
- Attribute types (String, Int64, Bool, List, Map, Set, Object, Dynamic)
- Attribute properties (Required, Optional, Computed, Sensitive, DeprecationMessage)
- Blocks for nested structures
- SingleNestedAttribute vs ListNestedAttribute vs MapNestedAttribute
- Blocks vs nested attributes (when to use which)
- MarkdownDescription for documentation generation
- Schema validation (Required + Computed is invalid, etc.)
- Default values and plan modifiers
- Code examples showing various schema patterns
- Common pitfalls (wrong nesting type, missing Computed, conflicting properties)

**Cross-references**:
- Link to types.md for attribute type details
- Link to validators.md for validation
- Link to plan-modifiers.md for defaults and modifiers

#### File: `docs/types.md` (NEW)
**Purpose**: Type system, conversions, null/unknown handling

**Content** (~300-350 lines):
- Framework type system overview (types.String, types.Int64, etc.)
- Type conversion methods (.ValueString(), .ValueInt64(), etc.)
- Null vs Unknown values (what they mean, how to check)
- .IsNull(), .IsUnknown() checks
- Creating type values (types.StringValue(), types.StringNull(), types.StringUnknown())
- Collection types (List, Map, Set) and element access
- Object types for complex structures
- Dynamic type for unknown-type-at-plan-time values
- Custom types (when and how to implement)
- Type validation and constraints
- Code examples for each type
- Common pitfalls (assuming not-null, using Go types instead of framework types)

**Cross-references**:
- Link to schema.md for schema attribute definitions
- Link to resources.md for usage in CRUD operations
- Link to validators.md for type-specific validators

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist
[ -s docs/schema.md ] && echo "✓ docs/schema.md has content"
[ -s docs/types.md ] && echo "✓ docs/types.md has content"

# Verify line counts
wc -l docs/schema.md  # Should be 350-400
wc -l docs/types.md  # Should be 300-350

# Check for key sections
grep -q "## Attribute Types" docs/schema.md && echo "✓ Attribute types section present"
grep -q "## Blocks" docs/schema.md && echo "✓ Blocks section present"
grep -q "## Null vs Unknown" docs/types.md && echo "✓ Null/unknown section present"
```

**Manual Verification**:
- Schema examples cover all attribute types
- Nested structures are clearly explained
- Type conversion patterns are demonstrated
- Null/unknown handling is thorough
- Cross-references work

### Success Criteria

#### Automated:
- [ ] docs/schema.md exists and is 350-400 lines
- [ ] docs/types.md exists and is 300-350 lines
- [ ] All attribute types documented
- [ ] Nested structures documented
- [ ] Type conversion methods documented

#### Manual:
- [ ] Schema patterns cover simple and complex cases
- [ ] Block vs nested attribute distinction is clear
- [ ] Type system is thoroughly explained
- [ ] Null vs unknown values are clearly differentiated
- [ ] Conversion examples are practical and clear
- [ ] Common pitfalls are highlighted

---

## Phase 5: Validation & Modifiers Documentation

### Overview
Document validators (built-in and custom) and plan modifiers (UseStateForUnknown, RequiresReplace, custom). Critical for schema validation and plan modification.

### Development Approach
1. Write docs/validators.md covering built-in and custom validators
2. Write docs/plan-modifiers.md with emphasis on UseStateForUnknown
3. Show validator composition and cross-attribute validation
4. Explain plan modification use cases
5. Cover testing validators and modifiers

### Changes Required

#### File: `docs/validators.md` (NEW)
**Purpose**: Built-in validators, custom validators, cross-attribute validation

**Content** (~250-300 lines):
- Validator purpose and when to use
- Built-in validators by type (stringvalidator, int64validator, listvalidator, etc.)
- Common validators (LengthAtLeast, LengthBetween, OneOf, RegexMatches, etc.)
- Validator composition (All, Any, AtLeastOneOf, ExactlyOneOf, etc.)
- Cross-attribute validation patterns
- Custom validator implementation (validator.String, validator.Int64, etc.)
- ValidateXxx methods and diagnostics
- Code examples for each validator category
- Common pitfalls (validators on computed attributes, conflicting validators)

**Cross-references**:
- Link to schema.md for validator usage in schemas
- Link to plan-modifiers.md for related functionality
- Link to testing.md for testing validators

#### File: `docs/plan-modifiers.md` (NEW)
**Purpose**: Plan modifiers, UseStateForUnknown pattern, RequiresReplace, custom

**Content** (~250-300 lines):
- Plan modifier purpose and when to use
- UseStateForUnknown (CRITICAL for computed attributes in Create)
- RequiresReplace (force resource replacement on attribute change)
- RequiresReplaceIf (conditional replacement)
- Default values (use with caution, prefer computed)
- Custom plan modifier implementation
- PlanModifyXxx methods
- Code examples showing common patterns
- Common pitfalls (missing UseStateForUnknown on computed, overusing RequiresReplace)

**Cross-references**:
- Link to schema.md for plan modifier usage in schemas
- Link to resources.md for plan modification in resource lifecycle
- Link to validators.md for related functionality

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist
[ -s docs/validators.md ] && echo "✓ docs/validators.md has content"
[ -s docs/plan-modifiers.md ] && echo "✓ docs/plan-modifiers.md has content"

# Verify line counts
wc -l docs/validators.md  # Should be 250-300
wc -l docs/plan-modifiers.md  # Should be 250-300

# Check for key sections
grep -q "## Built-in Validators" docs/validators.md && echo "✓ Built-in validators section present"
grep -q "## UseStateForUnknown" docs/plan-modifiers.md && echo "✓ UseStateForUnknown section present"
```

**Manual Verification**:
- Validator examples cover common use cases
- Custom validator implementation is clear
- UseStateForUnknown pattern is emphasized
- Plan modifier use cases are explained
- Cross-references work

### Success Criteria

#### Automated:
- [ ] docs/validators.md exists and is 250-300 lines
- [ ] docs/plan-modifiers.md exists and is 250-300 lines
- [ ] Built-in validators documented by type
- [ ] Custom validator pattern documented
- [ ] UseStateForUnknown prominently documented

#### Manual:
- [ ] Validator composition patterns are clear
- [ ] Cross-attribute validation is demonstrated
- [ ] UseStateForUnknown importance is emphasized
- [ ] RequiresReplace use cases are explained
- [ ] Custom implementations have complete examples
- [ ] Common pitfalls are highlighted

---

## Phase 6: Advanced Features & Testing Documentation

### Overview
Document functions, actions, ephemeral resources, and comprehensive testing patterns. These complete the framework capability coverage.

### Development Approach
1. Write docs/functions.md covering provider functions
2. Write docs/advanced.md covering actions and ephemeral resources
3. Write docs/testing.md with comprehensive testing patterns
4. Cover both unit testing (testify/require) and acceptance testing
5. Provide testing examples for all resource types

### Changes Required

#### File: `docs/functions.md` (NEW)
**Purpose**: Provider functions, parameters, returns, HCL usage

**Content** (~200-250 lines):
- function.Function interface
- Function implementation pattern
- Parameters and returns
- Function documentation (Metadata, Definition)
- Run method implementation
- HCL usage examples (calling from Terraform)
- Variadic parameters
- Error handling in functions
- Code examples
- Common pitfalls (incorrect parameter types, not validating input)

**Cross-references**:
- Link to provider.md for registering functions
- Link to types.md for parameter/return types
- Link to testing.md for testing functions

#### File: `docs/advanced.md` (NEW)
**Purpose**: Actions and ephemeral resources (session-scoped)

**Content** (~200-250 lines):
- Actions overview (action.Action interface)
- Ephemeral resources overview (ephemeral.EphemeralResource interface)
- Open/Close lifecycle for ephemeral resources
- Use cases (credentials, temporary resources)
- Implementation patterns
- Code examples
- When to use vs regular resources
- Common pitfalls

**Cross-references**:
- Link to provider.md for registering actions/ephemeral
- Link to resources.md for comparison
- Link to testing.md for testing ephemeral resources

#### File: `docs/testing.md` (NEW)
**Purpose**: Unit and acceptance testing patterns

**Content** (~300-350 lines):
```markdown
# Testing

Comprehensive testing ensures provider reliability and correctness. terraform-plugin-framework supports both unit testing (testify/require) and acceptance testing (terraform-plugin-testing).

## Testing Philosophy

**Test Types**:
- **Unit Tests**: Test individual methods (Schema, CRUD operations) in isolation
- **Acceptance Tests**: Test full provider integration with Terraform
- **Mock-Based**: Use mocks for external APIs in unit tests
- **Real Infrastructure**: Acceptance tests can use real or mock APIs

**When to Use Each**:
- Unit tests: Fast feedback, test edge cases, validate logic
- Acceptance tests: Verify Terraform integration, test full lifecycle

## Unit Testing

### Setup

```go
import (
    "testing"

    "github.com/stretchr/testify/require"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

func TestPetResource_Create(t *testing.T) {
    // Test implementation
}
```

**Follow go-dev-guidelines**:
- Use testify/require for assertions (not assert)
- Separate positive and negative tests
- Never use table-driven tests
- Use mockery for generating mocks

### Testing Schema

```go
func TestPetResource_Schema(t *testing.T) {
    resource := &PetResource{}
    req := resource.SchemaRequest{}
    resp := &resource.SchemaResponse{}

    resource.Schema(context.Background(), req, resp)

    require.NoError(t, resp.Diagnostics)
    require.NotNil(t, resp.Schema)

    // Validate schema structure
    require.Contains(t, resp.Schema.Attributes, "id")
    require.Contains(t, resp.Schema.Attributes, "name")

    // Validate attribute properties
    idAttr := resp.Schema.Attributes["id"].(schema.StringAttribute)
    require.True(t, idAttr.Computed)

    nameAttr := resp.Schema.Attributes["name"].(schema.StringAttribute)
    require.True(t, nameAttr.Required)
}
```

### Testing Create

```go
func TestPetResource_Create(t *testing.T) {
    // Setup mock client
    mockClient := &mocks.Client{}
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(&api.Pet{
        ID:      "pet-123",
        Name:    "Fluffy",
        Species: "cat",
    }, nil)

    resource := &PetResource{
        client: mockClient,
    }

    // Create request with plan
    req := resource.CreateRequest{}
    req.Plan = /* TBD: tfsdk.Plan setup */

    resp := &resource.CreateResponse{}

    // Execute Create
    resource.Create(context.Background(), req, resp)

    // Verify
    require.False(t, resp.Diagnostics.HasError())
    mockClient.AssertExpectations(t)

    // Verify state was set
    var state PetResourceModel
    diags := resp.State.Get(context.Background(), &state)
    require.False(t, diags.HasError())
    require.Equal(t, "pet-123", state.ID.ValueString())
}
```

### Testing Create Error

```go
func TestPetResource_Create_Error(t *testing.T) {
    // Setup mock client with error
    mockClient := &mocks.Client{}
    mockClient.On("CreatePet", mock.Anything, mock.Anything).Return(
        nil,
        errors.New("API error"),
    )

    resource := &PetResource{
        client: mockClient,
    }

    req := resource.CreateRequest{}
    resp := &resource.CreateResponse{}

    resource.Create(context.Background(), req, resp)

    // Verify error diagnostic
    require.True(t, resp.Diagnostics.HasError())
    require.Contains(t, resp.Diagnostics.Errors()[0].Summary(), "Error creating pet")
}
```

**Key Patterns**:
- Separate positive and negative tests
- Use mocks for external dependencies
- Verify diagnostics (HasError(), Errors())
- Verify state is set correctly
- Mock.AssertExpectations() ensures all mocked methods were called

## Acceptance Testing

### Setup

```go
import (
    "testing"

    "github.com/hashicorp/terraform-plugin-testing/helper/resource"
)

func TestAccPetResource(t *testing.T) {
    resource.Test(t, resource.TestCase{
        PreCheck:                 func() { testAccPreCheck(t) },
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Test steps
        },
    })
}
```

### Basic CRUD Test

```go
func TestAccPetResource_basic(t *testing.T) {
    resource.Test(t, resource.TestCase{
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Create and Read
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("myprovider_pet.test", "name", "Fluffy"),
                    resource.TestCheckResourceAttr("myprovider_pet.test", "species", "cat"),
                    resource.TestCheckResourceAttrSet("myprovider_pet.test", "id"),
                ),
            },
            // Update and Read
            {
                Config: testAccPetResourceConfig("Fluffy-Updated", "cat"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("myprovider_pet.test", "name", "Fluffy-Updated"),
                    resource.TestCheckResourceAttr("myprovider_pet.test", "species", "cat"),
                ),
            },
            // Import
            {
                ResourceName:      "myprovider_pet.test",
                ImportState:       true,
                ImportStateVerify: true,
            },
        },
    })
}

func testAccPetResourceConfig(name, species string) string {
    return fmt.Sprintf(`
resource "myprovider_pet" "test" {
  name    = %[1]q
  species = %[2]q
}
`, name, species)
}
```

### Testing Validation Errors

```go
func TestAccPetResource_invalidName(t *testing.T) {
    resource.Test(t, resource.TestCase{
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config:      testAccPetResourceConfig("", "cat"),
                ExpectError: regexp.MustCompile("name must be at least 1 character"),
            },
        },
    })
}
```

### Testing Plan Changes

```go
func TestAccPetResource_updateSpecies(t *testing.T) {
    resource.Test(t, resource.TestCase{
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            {
                Config: testAccPetResourceConfig("Fluffy", "cat"),
            },
            {
                Config: testAccPetResourceConfig("Fluffy", "dog"),
                Check: resource.ComposeAggregateTestCheckFunc(
                    resource.TestCheckResourceAttr("myprovider_pet.test", "species", "dog"),
                ),
            },
        },
    })
}
```

**Key Patterns**:
- Each TestStep is a Terraform apply
- Check functions verify state after apply
- ExpectError tests validation and error cases
- ImportState tests `terraform import` functionality
- Config strings use %q for proper quoting

## Testing Best Practices

### Positive Tests
```go
func TestPetResource_Create(t *testing.T) {
    // Test successful create
}

func TestPetResource_Create_WithOptionalFields(t *testing.T) {
    // Test create with optional fields
}
```

### Negative Tests
```go
func TestPetResource_Create_APIError(t *testing.T) {
    // Test create with API error
}

func TestPetResource_Create_ValidationError(t *testing.T) {
    // Test create with validation error
}
```

**Separate positive and negative tests** (go-dev-guidelines rule).

### Test Organization

```
internal/provider/
├── pet_resource.go
├── pet_resource_test.go          # Unit tests
├── pet_resource_acc_test.go      # Acceptance tests
└── mocks/
    └── client.go                  # Generated mocks
```

### Mocking

Use mockery to generate mocks:
```bash
mockery --name=Client --dir=internal/api --output=internal/api/mocks
```

```go
// in test
mockClient := &mocks.Client{}
mockClient.On("CreatePet", mock.Anything, mock.MatchedBy(func(req api.CreatePetRequest) bool {
    return req.Name == "Fluffy"
})).Return(&api.Pet{
    ID: "pet-123",
    Name: "Fluffy",
}, nil)
```

## Common Testing Pitfalls

⚠️ **Not Using testify/require**: Use require, not assert. require stops test on failure, assert continues (can cause cascading failures).

⚠️ **Table-Driven Tests**: Don't use table-driven tests per go-dev-guidelines. Write explicit test functions.

⚠️ **Mixing Positive and Negative**: Separate success and error tests into different functions.

⚠️ **Not Testing Errors**: Test error paths (API failures, validation errors) in separate negative tests.

⚠️ **Incomplete Acceptance Tests**: Test create, update, delete, and import in acceptance tests.

⚠️ **Not Cleaning Up**: Acceptance tests should clean up resources. Use PreCheck and CheckDestroy.

## Cross-References

- [Resources](resources.md) - What to test in resources
- [Data Sources](data-sources.md) - Testing data sources
- [Validators](validators.md) - Testing custom validators
- [Functions](functions.md) - Testing provider functions
- [Go Dev Guidelines](https://tessl.io/registry/go-dev-guidelines) - Testing patterns (testify/require, mockery)

## External Resources

- [terraform-plugin-testing](https://github.com/hashicorp/terraform-plugin-testing)
- [testify/require](https://pkg.go.dev/github.com/stretchr/testify/require)
- [mockery](https://github.com/vektra/mockery)
```

**Reasoning**:
- Comprehensive coverage of unit and acceptance testing
- Follows go-dev-guidelines patterns (testify/require, no table-driven, separate positive/negative)
- Practical examples for both test types
- Clear testing organization guidance
- Emphasizes common testing pitfalls

### Testing Strategy

**Automated Verification**:
```bash
# Verify files exist
[ -s docs/functions.md ] && echo "✓ docs/functions.md has content"
[ -s docs/advanced.md ] && echo "✓ docs/advanced.md has content"
[ -s docs/testing.md ] && echo "✓ docs/testing.md has content"

# Verify line counts
wc -l docs/functions.md  # Should be 200-250
wc -l docs/advanced.md  # Should be 200-250
wc -l docs/testing.md  # Should be 300-350
```

**Manual Verification**:
- Function implementation patterns are clear
- Ephemeral resource lifecycle is explained
- Testing patterns follow go-dev-guidelines
- Both unit and acceptance testing covered
- Examples are complete and actionable

### Success Criteria

#### Automated:
- [ ] docs/functions.md exists and is 200-250 lines
- [ ] docs/advanced.md exists and is 200-250 lines
- [ ] docs/testing.md exists and is 300-350 lines
- [ ] All files have required sections

#### Manual:
- [ ] Function implementation is clearly documented
- [ ] Ephemeral resource use cases are explained
- [ ] Unit testing patterns follow go-dev-guidelines
- [ ] Acceptance testing patterns are comprehensive
- [ ] Testing examples cover CRUD, errors, and edge cases
- [ ] Cross-references to go-dev-guidelines tile work

---

## Phase 7: Rules & Steering Files

### Overview
Create best practices rules that agents follow automatically. These provide subjective guidance separate from technical documentation.

### Development Approach
1. Create rules/ directory
2. Write 5 rules files covering key best practices
3. Keep rules concise and actionable
4. Focus on "always do X" and "never do Y" patterns
5. Reference documentation for details

### Changes Required

#### File: `rules/diagnostics.md` (NEW)
**Purpose**: Always check diagnostics pattern

**Content** (~100 lines):
```markdown
# Diagnostics Best Practices

Always check diagnostics after operations and return early on errors.

## Rule: Always Check Diagnostics

After any operation that returns diagnostics (req.Plan.Get(), req.State.Get(), resp.State.Set()), **always** check if errors occurred:

```go
var plan MyModel
diags := req.Plan.Get(ctx, &plan)
resp.Diagnostics.Append(diags...)
if resp.Diagnostics.HasError() {
    return  // CRITICAL: Return early
}
```

**Why**: Continuing after errors leads to nil pointer panics or incorrect behavior.

## Rule: Return Early on Errors

Never continue execution after diagnostics has errors:

```go
// ✅ CORRECT
if resp.Diagnostics.HasError() {
    return
}
// Continue with logic

// ❌ WRONG - Continuing despite errors
if resp.Diagnostics.HasError() {
    // Log or something
}
// Continuing despite errors - will panic!
```

## Rule: Add Helpful Error Messages

When adding errors to diagnostics, include context:

```go
// ✅ CORRECT - Specific, actionable error
resp.Diagnostics.AddError(
    "Error creating pet",
    fmt.Sprintf("Could not create pet %q: %s", plan.Name.ValueString(), err),
)

// ❌ WRONG - Generic, unhelpful error
resp.Diagnostics.AddError("Error", err.Error())
```

## Rule: Use Append for Diagnostics

Use `Append()` to collect diagnostics, don't overwrite:

```go
// ✅ CORRECT
resp.Diagnostics.Append(diags...)

// ❌ WRONG - Loses previous diagnostics
resp.Diagnostics = diags
```

## Examples

See [Resources](../docs/resources.md) and [Data Sources](../docs/data-sources.md) for comprehensive examples.
```

#### File: `rules/state-management.md` (NEW)
**Purpose**: State consistency, UseStateForUnknown patterns

**Content** (~150 lines):
- Always set state in CRUD operations
- Use UseStateForUnknown for computed attributes in Create
- State is source of truth, not plan
- Handle null vs unknown values correctly
- Examples and anti-patterns

#### File: `rules/schema-design.md` (NEW)
**Purpose**: Schema design patterns, attribute modifiers

**Content** (~150 lines):
- Schema design principles (minimize breaking changes, use optional)
- Computed attribute patterns
- When to use blocks vs nested attributes
- Validation vs plan modifiers
- Examples of good schema design

#### File: `rules/testing-standards.md` (NEW)
**Purpose**: testify/require requirements, test organization

**Content** (~150 lines):
- Always use testify/require (not assert)
- Never use table-driven tests
- Separate positive and negative tests
- Use mockery for mocks
- Test organization (separate unit and acceptance)
- Examples

#### File: `rules/common-pitfalls.md` (NEW)
**Purpose**: Consolidated gotchas from all areas

**Content** (~200 lines):
- Not checking diagnostics
- Not setting state
- Missing UseStateForUnknown
- Type conversion errors
- Read not handling 404
- Using plan as source of truth in Update
- Delete errors on already-deleted
- Validators on computed attributes
- And more...
- Each with brief explanation and reference to docs

### Testing Strategy

**Automated Verification**:
```bash
# Verify all rules files exist
[ -s rules/diagnostics.md ] && echo "✓ rules/diagnostics.md exists"
[ -s rules/state-management.md ] && echo "✓ rules/state-management.md exists"
[ -s rules/schema-design.md ] && echo "✓ rules/schema-design.md exists"
[ -s rules/testing-standards.md ] && echo "✓ rules/testing-standards.md exists"
[ -s rules/common-pitfalls.md ] && echo "✓ rules/common-pitfalls.md exists"

# Verify tile.json references all rules
jq '.steering.rules | length' tile.json  # Should be 5
```

**Manual Verification**:
- Rules are concise and actionable
- Each rule has clear "always" or "never" guidance
- Code examples demonstrate correct and incorrect patterns
- Cross-references to docs work

### Success Criteria

#### Automated:
- [ ] All 5 rules files exist in rules/ directory
- [ ] Each file has content (~100-200 lines)
- [ ] tile.json steering array has 5 entries
- [ ] All rules files referenced in tile.json

#### Manual:
- [ ] Rules are clear and actionable
- [ ] Each rule explains "why" not just "what"
- [ ] Examples show correct and incorrect patterns
- [ ] Cross-references to documentation work
- [ ] Rules complement (not duplicate) documentation

---

## Phase 8: Testing & Publishing

### Overview
Validate the complete tile locally, test with real Terraform provider project, and prepare for publishing to Tessl registry.

### Development Approach
1. Local tile installation and testing
2. Create sample provider project
3. Test tile effectiveness with agent
4. Iterate based on findings
5. Prepare for publishing (version, changelog)
6. Publish to registry

### Testing Workflow

#### Step 1: Local Installation
```bash
cd /path/to/tessl-tile-terraform-plugin-framework
tessl install .
```

**Verify**:
- Tile installs without errors
- tile.json is valid
- All referenced files exist

#### Step 2: Create Test Provider
```bash
mkdir test-provider
cd test-provider
go mod init github.com/example/terraform-provider-test
go get github.com/hashicorp/terraform-plugin-framework@v1.17.0
```

#### Step 3: Test with Agent
Use Claude Code or Cursor to build components:

**Test 1: Simple Resource**
```
Create a Terraform resource for managing a "Pet" with attributes:
- id (string, computed)
- name (string, required)
- species (string, required)
- age (int, optional)

Use terraform-plugin-framework.
```

**Verify**:
- Agent references tile documentation
- Code follows patterns from docs (checks diagnostics, sets state, uses UseStateForUnknown)
- Code compiles without errors
- Agent applies rules (e.g., uses testify/require in tests)

**Test 2: Resource with Validation**
```
Add validators to the Pet resource:
- Name must be at least 1 character
- Species must be one of: dog, cat, bird, fish

Use terraform-plugin-framework.
```

**Verify**:
- Agent uses built-in validators correctly
- References validators.md documentation
- Validation works as expected

**Test 3: Resource with Nested Schema**
```
Add a "owner" nested attribute to Pet resource with:
- name (string, required)
- email (string, required, validated as email format)

Use terraform-plugin-framework.
```

**Verify**:
- Agent uses SingleNestedAttribute correctly
- References schema.md for nested structures
- Nested validation works

**Test 4: Unit Tests**
```
Write unit tests for the Pet resource Create method.
Use terraform-plugin-framework and go-dev-guidelines.
```

**Verify**:
- Agent uses testify/require (not assert)
- Separates positive and negative tests
- Follows testing patterns from testing.md

#### Step 4: Iterate
Based on test findings:
- Update documentation where agent struggled
- Clarify ambiguous sections
- Add more examples for complex patterns
- Update rules if agent missed best practices

#### Step 5: Comprehensive Validation

**Documentation Quality**:
- [ ] All 12 docs files present and complete
- [ ] All 5 rules files present and complete
- [ ] README is comprehensive
- [ ] tile.json is valid and references all rules
- [ ] No TODO or placeholder text remains
- [ ] All code examples are syntactically valid
- [ ] All internal links work
- [ ] All external links work (no 404s)

**Content Quality**:
- [ ] Concepts are explained clearly
- [ ] Code examples support explanations
- [ ] Common pitfalls are highlighted
- [ ] Testing guidance is integrated
- [ ] Cross-references are helpful
- [ ] Agent can follow documentation to build providers

**Tile Functionality**:
- [ ] Tile installs locally without errors
- [ ] Agent references tile documentation when prompted
- [ ] Agent follows rules automatically
- [ ] Generated code compiles and passes go vet
- [ ] Generated code follows best practices

### Publishing Workflow

#### Option 1: GitHub Action

1. **Create workflow file** `.github/workflows/publish.yml`:
```yaml
name: Publish Tile
on:
  push:
    tags:
      - 'v*'
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: tesslio/publish@v1
        with:
          tessl_token: ${{ secrets.TESSL_TOKEN }}
```

2. **Tag and push**:
```bash
git tag v0.1.0
git push origin v0.1.0
```

#### Option 2: Manual Submission

1. Visit https://tessl.io/registry/skills/submit
2. Provide repository URL: https://github.com/nicholasjackson/tessl-tile-terraform-plugin-framework
3. Specify version: v0.1.0
4. Submit for evaluation

#### Post-Publish Verification

1. **Check registry**: Tile appears at https://tessl.io/registry
2. **Test installation from registry**:
```bash
# In fresh directory
tessl install nicholasjackson/terraform-plugin-framework
```

3. **Verify tile loaded**:
- Check `.tessl/` directory has tile content
- Check `.tessl/RULES.md` has consolidated rules
- Test agent references tile

### Success Criteria

#### Automated:
- [ ] Tile installs locally without errors
- [ ] All files referenced in tile.json exist
- [ ] tile.json is valid JSON
- [ ] Code examples compile (spot check 10-15 examples)
- [ ] No broken internal links (automated link checker)

#### Manual:
- [ ] Test provider project builds successfully
- [ ] Agent generates correct code using tile
- [ ] Agent follows rules from rules/
- [ ] Generated code passes go vet and go build
- [ ] Tile is published to registry
- [ ] Tile installs from registry successfully

---

## Implementation Notes

### Content Creation Tips

**Code Examples**:
- Adapt from official terraform-plugin-framework docs
- Use scaffolding template as reference
- Keep examples focused (20-50 lines)
- Show complete patterns, not fragments
- Include necessary imports

**Pitfalls**:
- Draw from GitHub issues, Stack Overflow, HashiCorp forums
- Test each pitfall with example that reproduces it
- Explain why it's a problem and how to fix
- Mark with ⚠️ emoji for visibility

**Testing Patterns**:
- Follow go-dev-guidelines for Go testing patterns
- Use testify/require (not assert)
- Separate positive and negative tests
- Show unit and acceptance test examples

**Cross-References**:
- Use relative markdown links: `[Resources](resources.md)`
- Use anchors for sections: `[Schema System](schema.md#attribute-types)`
- Reference rules: `[rules/state-management.md](../rules/state-management.md)`
- Link to external docs: `[HashiCorp Docs](https://developer.hashicorp.com/terraform/plugin/framework)`

### Time Estimates

- **Phase 1**: Foundation & Setup (~2 hours)
- **Phase 2**: Core Documentation (~4-5 hours)
- **Phase 3**: Resource & Data Source (~5-6 hours)
- **Phase 4**: Schema & Type System (~5-6 hours)
- **Phase 5**: Validation & Modifiers (~4-5 hours)
- **Phase 6**: Advanced Features & Testing (~5-6 hours)
- **Phase 7**: Rules & Steering (~3-4 hours)
- **Phase 8**: Testing & Publishing (~3-4 hours)
- **Total**: ~31-42 hours of focused work

### Quality Standards

- **Clarity**: Assume reader is learning terraform-plugin-framework for first time
- **Completeness**: Cover all major framework capabilities (comprehensive per user request)
- **Practicality**: Every concept has code example
- **Agent-Friendly**: Explain "why" and "when", not just "how"
- **Accuracy**: All information aligned with terraform-plugin-framework v1.17.0
- **Modularity**: Each file standalone, well cross-linked
- **Testing-Focused**: Testing guidance integrated throughout
- **Pitfall-Aware**: Common issues prominently highlighted

### Resources to Reference

- **Primary**: https://developer.hashicorp.com/terraform/plugin/framework
- **API Reference**: https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework
- **Examples**: https://github.com/hashicorp/terraform-provider-scaffolding-framework
- **Testing**: https://github.com/hashicorp/terraform-plugin-testing
- **Go Patterns**: Go-dev-guidelines tile for TDD, testify/require, mockery
- **Tessl**: https://docs.tessl.io for tile structure and best practices

## Success Definition

The tile is complete and successful when:

1. ✅ All 8 phases complete with success criteria met
2. ✅ README provides clear overview, testing, and publishing workflows
3. ✅ 12 documentation files cover all framework capabilities comprehensively
4. ✅ 5 rules files provide actionable best practices
5. ✅ tile.json correctly configured with steering
6. ✅ Agent can build Terraform providers using tile guidance
7. ✅ Code examples are clear, accurate, and follow best practices
8. ✅ Common pitfalls are highlighted throughout
9. ✅ Testing guidance enables well-tested providers
10. ✅ Local testing validates tile effectiveness
11. ✅ Tile publishes successfully to Tessl registry
12. ✅ No TODOs or placeholders remain
13. ✅ Ready for production use by agents

---

*This plan covers implementation of terraform-plugin-framework tile v0.1.0 with multi-file documentation structure, rules/steering, testing workflow, and publishing preparation.*
