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

## Local Validation

The `test/` directory contains a two-phase validation script that uses Claude to build a provider from scratch, then validates the output compiles, passes vet, and passes acceptance tests.

### Prerequisites

- Docker (for the local Petstore API)
- Claude CLI (`claude`)
- Tessl CLI (`tessl`)
- Go 1.21+

### Running

```bash
bash test/validate.sh
```

This will:

1. Start a local Swagger Petstore API in Docker (port 18080)
2. Clone the [HashiCorp scaffold](https://github.com/hashicorp/terraform-provider-scaffolding-framework) at a pinned commit
3. Install the tile under test from the local directory
4. **Phase 1**: Run Claude to build CRUD resources for the Petstore API
5. Validate: `go build`, `go vet`, `TF_ACC=1 go test`
6. **Phase 2**: Run Claude to add an ephemeral resource to the existing provider
7. Validate: `go build`, `go vet`, `go test`

Output is written to `test-output/` (gitignored).

### Test Files

| File | Purpose |
|------|---------|
| `test/validate.sh` | Main validation runner |
| `test/prompt.md` | Phase 1 prompt (CRUD provider from Petstore API) |
| `test/prompt-ephemeral.md` | Phase 2 prompt (add ephemeral resource) |
| `test/stream_output.py` | Streams Claude's JSON output to terminal |

## Tessl Evals

The `evals/` directory contains evaluation scenarios that run on Tessl's cloud infrastructure. Each scenario tests a specific terraform-plugin-framework capability.

### Scenarios

| Scenario | Capability | What It Tests |
|----------|-----------|---------------|
| 1 | `schema-validators-plan-modifiers` | OneOf/Between validators, UseStateForUnknown/RequiresReplace plan modifiers |
| 2 | `resource-crud` | New resource with full CRUD, API client, acceptance tests |
| 3 | `data-source-import-state` | Data source Read method, ImportStatePassthroughID |
| 4 | `provider-configuration` | Provider schema with env var fallback, ProviderData wiring |
| 5 | `provider-function` | Provider-defined function with Definition/Run, error handling, unit tests |

All scenarios start from the official [HashiCorp scaffold](https://github.com/hashicorp/terraform-provider-scaffolding-framework) pinned at commit `3f9b7d20`.

### Running Evals

```bash
# Run all scenarios (baseline + with-tile)
tessl eval run

# View results
tessl eval view --last

# Force re-run (ignore cached results)
tessl eval run --force

# Retry a failed run
tessl eval retry <run-id>
```

Each scenario runs twice: a **baseline** (without the tile) and **with-context** (with the tile). Scores are compared to measure the tile's impact.

### Eval Structure

Each scenario directory contains:

```
evals/scenario-N/
  task.md          # The prompt given to the agent
  criteria.json    # Weighted checklist (scores sum to 100)
  capability.text  # Capability tag for grouping
```

### Adding a New Scenario

1. Create `evals/scenario-N/` with `task.md`, `criteria.json`, and `capability.text`
2. Ensure `criteria.json` scores sum to 100
3. Add the capability to `evals/capabilities.json`
4. Update `evals/summary.json` scenario count
5. Run `tessl tile lint` to verify
6. Run `tessl eval run` to test

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
