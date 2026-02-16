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
