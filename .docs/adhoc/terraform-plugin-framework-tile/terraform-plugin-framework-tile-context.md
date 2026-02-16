# Terraform Plugin Framework Tile - Context & Dependencies

**Last Updated**: 2026-02-16
**Type**: Documentation Creation (Tessl Tile)

## Quick Summary

Create comprehensive documentation for `github.com/hashicorp/terraform-plugin-framework` in a Tessl tile format to help coding agents build Terraform providers. Documentation covers all major APIs, includes code examples, emphasizes testing patterns, schema design, common pitfalls, and Go-specific integration patterns.

## Key Files & Locations

### Files to Create/Modify:
- `README.md` - Repository overview, installation, usage, testing, publishing (~150 lines)
- `tile.json` - Add steering/rules configuration
- `docs/index.md` - Overview + navigation TOC (200-250 lines)
- `docs/quick-start.md` - Getting started guide (200-250 lines)
- `docs/provider.md` - Provider implementation (300-350 lines)
- `docs/resources.md` - Resources CRUD (350-400 lines)
- `docs/data-sources.md` - Data sources (200-250 lines)
- `docs/schema.md` - Schema system (350-400 lines)
- `docs/types.md` - Type system (300-350 lines)
- `docs/validators.md` - Validators (250-300 lines)
- `docs/plan-modifiers.md` - Plan modifiers (250-300 lines)
- `docs/functions.md` - Functions (200-250 lines)
- `docs/advanced.md` - Actions & ephemeral (200-250 lines)
- `docs/testing.md` - Testing patterns (300-350 lines)
- `rules/diagnostics.md` - Diagnostics best practices (~100 lines)
- `rules/state-management.md` - State patterns (~150 lines)
- `rules/schema-design.md` - Schema patterns (~150 lines)
- `rules/testing-standards.md` - Testing requirements (~150 lines)
- `rules/common-pitfalls.md` - Gotchas consolidated (~200 lines)

### Files to Reference:
- `tile.json:1-7` - Tile manifest configuration (already correct)
- `.claude/settings.local.json:1-7` - Claude permissions (already configured)
- `.docs/adhoc/terraform-plugin-framework-tile/` - Planning documentation (this directory)

### External Resources to Reference:
- **HashiCorp Documentation**: https://developer.hashicorp.com/terraform/plugin/framework
- **Package Documentation**: https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework
- **Scaffolding Template**: https://github.com/hashicorp/terraform-provider-scaffolding-framework
- **Plugin Docs Tool**: https://github.com/hashicorp/terraform-plugin-docs
- **Tessl Publish Action**: https://github.com/tesslio/publish
- **Tessl Registry**: https://tessl.io/registry

## Dependencies

### Code Dependencies:
None - this is documentation only, no code implementation required.

### External Dependencies:
- Access to terraform-plugin-framework documentation sources
- Understanding of Terraform provider concepts
- Knowledge of Go idioms (reference separate Go tile)

### Tile Dependencies:
- Separate Go best practices tile (for general Go patterns)
- terraform-plugin-framework package itself (described by this tile)

## Key Technical Decisions

1. **Multi-File Structure**: Use multiple documentation files in `docs/` directory with `index.md` as entrypoint. Researched existing Tessl tiles (pypi-yapf, pypi-bokeh, etc.) and confirmed this is standard practice. Provides better context management with smaller chunks (~250-400 lines per file instead of 3000+ in one file).

2. **Comprehensive Coverage**: Document all major terraform-plugin-framework capabilities (providers, resources, data sources, schemas, types, validators, plan modifiers, functions, actions, ephemeral resources) per user requirements.

3. **Code Snippets Only**: Include focused 20-50 line code examples showing patterns, not complete working provider. Reference official HashiCorp scaffolding for full examples.

4. **Emphasis Areas**: Prioritize content on:
   - Common pitfalls & gotchas (dedicated section + integrated throughout)
   - Testing patterns (dedicated section with testify/require, acceptance tests)
   - Schema design patterns (comprehensive schema section)
   - Go-specific patterns (where terraform-plugin-framework intersects with Go)

5. **No Migration Content**: Framework-only focus, no content about migrating from terraform-plugin-sdk. Assumes agents are building new providers.

6. **Reference External Resources**: Link to official HashiCorp docs and examples rather than duplicating content. Focus on agent-friendly explanations and patterns.

7. **Use Rules/Steering**: Separate subjective best practices and guidelines into `rules/` directory as steering content. This gets consolidated into `.tessl/RULES.md` for agents to follow automatically. Includes diagnostics patterns, state management, schema design, testing standards, and common pitfalls.

8. **README for Discovery**: Create comprehensive README.md following spec-driven-development-tile pattern with sections for: what the tile does, installation, usage, what's included, why it's useful, how it works, testing instructions, and publishing workflow.

## Content Structure

### Documentation Files (docs/ - 12 files, ~3300 lines total)

1. **index.md** - Overview, what it is, table of contents
2. **quick-start.md** - Installation, first provider, when to use
3. **provider.md** - Provider interface, configuration, server setup
4. **resources.md** - Resource CRUD, state management, lifecycle
5. **data-sources.md** - Data source implementation
6. **schema.md** - Schema system, attributes, blocks, nesting
7. **types.md** - Type system, conversions, null/unknown
8. **validators.md** - Built-in and custom validators
9. **plan-modifiers.md** - Plan modifiers, UseStateForUnknown
10. **functions.md** - Provider functions
11. **advanced.md** - Actions and ephemeral resources
12. **testing.md** - Unit and acceptance testing

Each file: concepts + code examples + cross-links to other files and rules

### Rules/Steering (rules/ - 5 files, ~750 lines total)

1. **diagnostics.md** - Always check diagnostics pattern
2. **state-management.md** - State consistency, UseStateForUnknown usage
3. **schema-design.md** - Schema design patterns, attribute modifiers
4. **testing-standards.md** - testify/require requirements, test organization
5. **common-pitfalls.md** - Consolidated gotchas from all areas

Rules provide subjective guidance that agents follow automatically

## Integration Points

### Tessl Ecosystem:
- **tile.json** → references `docs/index.md`
- **Tessl Registry** → tile published for agent consumption
- **Go Best Practices Tile** → referenced for general Go patterns

### terraform-plugin-framework Ecosystem:
- **terraform-plugin-go** → underlying protocol layer (abstracted away)
- **Terraform CLI** → consumes providers built with framework
- **terraform-plugin-docs** → generates provider documentation
- **Provider scaffolding** → template for new providers

## Environment Requirements

### Development:
- Any text editor (documentation creation)
- Markdown linter/preview (optional but recommended)

### Testing:
- **Tessl CLI**: For local tile testing (`npm i -g @tessl/cli`)
- **Test Project**: Sample Terraform provider project to test tile effectiveness
- **Claude Code or Cursor**: MCP-compatible agent for testing

### Publishing:
- **GitHub Repository**: Public repo for tile hosting
- **Tessl Account**: For registry submission
- **GitHub Actions**: For automated publishing (optional)

## Scope Boundaries

### In Scope:
✅ All terraform-plugin-framework APIs and patterns
✅ Code examples showing usage
✅ Testing patterns for providers
✅ Schema design guidance
✅ Common pitfalls and debugging
✅ Go-specific framework integration patterns
✅ References to official resources
✅ README with installation, usage, and testing instructions
✅ Local testing workflow
✅ Publishing to Tessl registry workflow

### Out of Scope:
❌ Complete working provider example
❌ Migration from terraform-plugin-sdk
❌ General Go best practices (separate tile)
❌ terraform-plugin-go details (lower level)
❌ Terraform language/configuration syntax
❌ Provider-specific implementation details
❌ Automated CI/CD pipeline setup (mention but don't implement)

## Success Metrics

- **Comprehensive**: All major framework areas documented
- **Practical**: Code examples for every major concept
- **Agent-Friendly**: Clear explanations of "why" and "how"
- **Pitfall-Aware**: Common issues highlighted
- **Test-Focused**: Testing guidance integrated throughout
- **Well-Structured**: Clear navigation and cross-links
- **Accurate**: Aligned with terraform-plugin-framework v1.17.0

## Related Documentation

- **Plan**: [terraform-plugin-framework-tile-plan.md](terraform-plugin-framework-tile-plan.md)
- **Research**: [terraform-plugin-framework-tile-research.md](terraform-plugin-framework-tile-research.md)
- **Tasks**: [terraform-plugin-framework-tile-tasks.md](terraform-plugin-framework-tile-tasks.md)
- **Tile Manifest**: [/tile.json](/tile.json)
- **Current Docs**: [/docs/index.md](/docs/index.md)
