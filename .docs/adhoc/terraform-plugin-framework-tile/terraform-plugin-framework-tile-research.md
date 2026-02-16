# Terraform Plugin Framework Tile - Research & Working Notes

**Research Date**: 2026-02-16
**Researchers**: Claude + nicj

## Initial Understanding

Create a Tessl tile for `github.com/hashicorp/terraform-plugin-framework` that will help coding agents build Terraform providers. The tile should contain comprehensive documentation about the package including APIs, patterns, examples, and best practices.

## Research Process

### Resources Consulted:

1. **Tessl Documentation** (docs.tessl.io)
   - Web search revealed: Tessl tiles are versioned bundles containing skills, documentation, rules, and "steering" (guidelines)
   - Tile structure: tile.json manifest + docs/ directory + optional test/ directory
   - Tiles help agents understand how to use technologies effectively

2. **Current Repository State**:
   - `tile.json:1-7` - Manifest configured, points to docs/index.md
   - `docs/index.md:1-24` - Template file with TODO sections (Overview, Installation, Basic Usage, API Reference, Best Practices)
   - `.claude/settings.local.json:1-7` - Permissions configured for docs.tessl.io

3. **terraform-plugin-framework Package Analysis** (pkg.go.dev):
   - Comprehensive Go SDK for building Terraform providers
   - Version: v1.17.0 (GA with semantic versioning)
   - Go 1.24+ required
   - Main package groups:
     - `provider/` - Provider implementation
     - `resource/` - Managed resources (CRUD)
     - `datasource/` - Read-only data sources
     - `types/` - Data type system
     - `schema/` - Schema definitions
     - `function/` - Custom provider functions
     - `action/` - Provider actions
     - `ephemeral/` - Session-scoped resources
     - `path/`, `diag/`, `attr/` - Utilities

4. **Past Learnings Search** (iw-learnings):
   - No existing learnings about Tessl tiles or terraform-plugin-framework in this project

5. **Go Development Guidelines** (go-dev-guidelines):
   - Activated for Go-specific patterns integration
   - Will reference for testing patterns (TDD, testify/require, mockery)
   - User noted: "We should probably use a separate tile for go best practices"
   - Decision: Include Go-specific terraform-plugin-framework patterns, but reference Go tile for general Go best practices

### Questions Asked & Answers:

**Q1: What depth of coverage should the tile provide?**
A: **Comprehensive (All APIs)** - Cover all major areas: providers, resources, data sources, schemas, types, validators, functions, ephemeral resources, etc.

**Q2: Should the tile include actual code examples from a working provider?**
A: **Code snippets only** - Include code snippets in documentation but no complete runnable example. Reference HashiCorp examples.

**Q3: What areas are most important to emphasize for coding agents?**
A: **All of these** (multi-select):
- Common pitfalls & gotchas
- Testing patterns
- Schema design patterns
- Go-specific patterns
Plus user comment: "We should probably use a separate tile for go best practices"

**Q4: Should we include content about migrating from terraform-plugin-sdk?**
A: **No, framework-only** - Focus on building new providers with the framework, not migration.

## Key Discoveries

### Technical Discoveries:

1. **Tessl Tile Structure**:
   - `tile.json` contains name, version, summary, "describes" field (pkg reference), and docs path
   - Documentation goes in `docs/` directory with `index.md` as entry point
   - Can include "steering" rules (guidelines for agents)
   - Tiles are versioned and stored in Tessl registry

2. **terraform-plugin-framework Architecture**:
   - Built on top of `terraform-plugin-go` (abstracts protocol details)
   - Supports both tfprotov5 and tfprotov6 protocols
   - Organized into logical domains (provider, resource, datasource, etc.)
   - Rich type system with basetypes and custom type support
   - Schema-first approach with validators and plan modifiers

3. **Key Package Organization**:
   ```
   terraform-plugin-framework/
   ├── provider/          # Provider metadata, config, schema
   ├── resource/          # Resource CRUD operations
   │   └── schema/        # Resource schemas with validators, defaults, plan modifiers
   ├── datasource/        # Data source interfaces
   │   └── schema/        # Data source schemas
   ├── function/          # Custom Terraform functions
   ├── action/            # Provider actions
   ├── ephemeral/         # Ephemeral (session-scoped) resources
   ├── types/             # Type system (String, Int64, Bool, List, Map, Set, Object, Dynamic)
   │   └── basetypes/     # Base type implementations
   ├── attr/              # Type and value interfaces
   ├── path/              # Attribute path traversal
   ├── diag/              # Diagnostic system
   ├── schema/            # Common schema utilities and validators
   ├── tfsdk/             # Core framework types
   └── providerserver/    # Server hosting
   ```

4. **Official Learning Resources**:
   - HashiCorp Developer: developer.hashicorp.com/terraform/plugin/framework
   - Scaffolding template: github.com/hashicorp/terraform-provider-scaffolding-framework
   - HashiCups tutorial: Hands-on provider implementation
   - Plugin docs generator: terraform-plugin-docs tool

### Patterns to Follow:

1. **Documentation Organization**: Organize by major capability areas, not alphabetically by package
2. **Agent-Friendly Content**: Include "why" explanations, common pitfalls, and decision guidance
3. **Code Snippet Strategy**: Show minimal, focused examples rather than complete implementations
4. **Cross-References**: Link related concepts (e.g., types → schemas → validators)

### Constraints Identified:

1. **No Full Example Provider**: Per user request, no complete working example - code snippets only
2. **No Migration Content**: Focus on framework-only, not migration from SDK
3. **Separate Go Tile**: Reference separate Go tile for general Go best practices
4. **Framework Scope**: Cover terraform-plugin-framework only, not terraform-plugin-go or SDK

### README Requirements (Discovered 2026-02-16):

**Research findings:**
- README.md not explicitly required by Tessl but recommended for tile discovery
- Examined spec-driven-development-tile README structure
- Package tiles (cobra, gomega) appear auto-generated without custom READMEs
- Methodology tiles DO have comprehensive READMEs following clear pattern

**README Structure Pattern (from spec-driven-development-tile):**
1. Title and brief description with links
2. "What This Tile Does" section
3. Installation instructions (tessl CLI and npx methods)
4. Usage examples with prompts
5. "What's in This Tile" table listing files
6. "Why This Tile" explaining value
7. "How It Works" technical explanation
8. Links and license

**Decision:** Create README following this pattern, add sections for:
- Testing the tile locally
- Publishing to Tessl registry
- Contributing guidelines (optional)

### Testing & Publishing Workflow (Discovered 2026-02-16):

**Local Testing:**
- Use `tessl install <local-path>` to test tile locally before publishing
- Create test Terraform provider project to validate tile effectiveness
- Test with Claude Code or Cursor (MCP-compatible agents)
- Verify docs render correctly and rules are loaded

**Publishing Options:**
- **GitHub Action**: Use tesslio/publish action for automated publishing
- **Manual**: Submit to Tessl registry via tessl.io/registry/skills/submit
- **Version Management**: Follow semantic versioning in tile.json

**Verification:**
- Check tile appears in registry after publishing
- Test installation from registry in fresh environment
- Monitor agent success rates if Tessl provides metrics

## Design Decisions

### Decision 1: Documentation Structure
**Options considered:**
- **Option A**: Single large index.md file (~5000+ lines)
  - Pros: Simple, single file to edit
  - Cons: Hard to navigate, overwhelming for agents, large context
- **Option B**: Multi-file structure with topic pages
  - Pros: Better organization, smaller context chunks, easier to navigate
  - Cons: More files to manage
- **Option C**: Single file with clear sections and table of contents
  - Pros: Balance of simplicity and organization
  - Cons: Still quite long (3000-4000 lines)

**Chosen**: Option B (Multi-file structure)
**Rationale**: After researching existing Tessl tiles, multi-file documentation is standard and recommended:
- tile.json points to `docs/index.md` as entrypoint
- Index contains overview + TOC with links to other files
- Each major topic in separate file (~250-400 lines each)
- Smaller context chunks for agents to process
- Example tiles (pypi-yapf, pypi-bokeh, etc.) all use this pattern
- Total content same (~3300 lines) but better organized

### Decision 2: Content Depth per Section
**Options considered:**
- **Option A**: API reference style (list all types/methods)
  - Pros: Complete reference
  - Cons: Not agent-friendly, lacks context
- **Option B**: Tutorial style (step-by-step guides)
  - Pros: Easy to follow
  - Cons: Too prescriptive, limited coverage
- **Option C**: Conceptual + Practical (concepts + code patterns + pitfalls)
  - Pros: Balances understanding with practical application
  - Cons: Requires careful curation

**Chosen**: Option C (Conceptual + Practical)
**Rationale**: Agents need to understand both "what" (concepts) and "how" (patterns) plus "watch out for" (pitfalls). This aligns with user's emphasis on common pitfalls, testing, and schema design patterns.

### Decision 3: Code Example Format
**Options considered:**
- **Option A**: Minimal snippets (5-10 lines each)
- **Option B**: Medium examples (20-50 lines showing context)
- **Option C**: Complete examples (100+ lines, runnable)

**Chosen**: Option B (Medium examples)
**Rationale**: Per user request for "code snippets only" (not full provider), but snippets need enough context to be meaningful. 20-50 line examples show usage patterns without overwhelming.

### Decision 4: Testing Coverage
**Options considered:**
- **Option A**: Brief mention of testing
- **Option B**: Dedicated testing section with patterns
- **Option C**: Testing integrated throughout

**Chosen**: Option B + C (Dedicated section + integrated examples)
**Rationale**: User emphasized testing patterns as key focus area. Dedicated section covers testing comprehensively, while integration throughout shows testing for each capability.

### Decision 5: README and Publishing
**Options considered:**
- **Option A**: No README, minimal documentation
  - Pros: Less work, tile.json is sufficient
  - Cons: Poor discoverability, no testing/publishing guidance
- **Option B**: Basic README with tile description only
  - Pros: Simple, covers basics
  - Cons: Missing testing and publishing instructions
- **Option C**: Comprehensive README following tile patterns with testing/publishing
  - Pros: Professional, helps contributors, includes workflow guidance
  - Cons: More content to maintain

**Chosen**: Option C (Comprehensive README)
**Rationale**: User explicitly requested testing and publishing information. Following spec-driven-development-tile pattern ensures consistency with Tessl ecosystem. README serves multiple audiences: users discovering the tile, contributors wanting to test locally, and maintainers publishing updates.

## Content Organization Plan

The documentation will be organized into multiple files with rules/steering for best practices:

### Repository Structure
- **README.md** (~150 lines) - Overview, installation, usage, testing, publishing

### Documentation Files (docs/)
1. **index.md** (200-250 lines) - Overview, what it is, TOC with links to all pages
2. **quick-start.md** (200-250 lines) - Installation, first provider, when to use
3. **provider.md** (300-350 lines) - Provider interface, configuration, server setup
4. **resources.md** (350-400 lines) - Resource CRUD, state management, lifecycle
5. **data-sources.md** (200-250 lines) - Data source implementation, read-only patterns
6. **schema.md** (350-400 lines) - Schema system, attributes, blocks, nesting
7. **types.md** (300-350 lines) - Type system, conversions, null/unknown handling
8. **validators.md** (250-300 lines) - Built-in and custom validators
9. **plan-modifiers.md** (250-300 lines) - Plan modifiers, UseStateForUnknown patterns
10. **functions.md** (200-250 lines) - Provider functions, parameters, returns
11. **advanced.md** (200-250 lines) - Actions and ephemeral resources
12. **testing.md** (300-350 lines) - Unit and acceptance testing patterns

### Rules/Steering (rules/)
These provide subjective guidance and best practices for agents:
1. **diagnostics.md** - Always check diagnostics before proceeding
2. **state-management.md** - State consistency patterns, UseStateForUnknown
3. **schema-design.md** - Schema design patterns, attribute modifiers
4. **testing-standards.md** - testify/require requirements, test organization
5. **common-pitfalls.md** - Consolidated gotchas from all areas

Each doc file includes:
- Conceptual explanation
- Key interfaces/types
- Code examples
- Cross-links to related pages
- References to relevant rules

## Open Questions (During Research)

All questions resolved before finalizing plan:

- [x] **Q**: What depth of coverage? **A**: Comprehensive (all APIs)
- [x] **Q**: Include working example provider? **A**: No, code snippets only
- [x] **Q**: Key focus areas? **A**: Pitfalls, testing, schema design, Go patterns
- [x] **Q**: Include migration content? **A**: No, framework-only
- [x] **Q**: Single file or multi-file docs? **A**: Single file (tile convention)
- [x] **Q**: Reference Go best practices tile? **A**: Yes, for general Go patterns

## Implementation Notes

### Tessl Tile Specifics:
- tile.json already configured correctly
- docs/index.md is the target file (will replace template)
- No code implementation needed (documentation only)
- Can reference external resources (HashiCorp docs, scaffolding repo)

### Content Creation Strategy:
- Start with table of contents (navigation structure)
- Fill in each major section sequentially
- Include code examples from terraform-plugin-framework docs/examples
- Add pitfalls and best practices based on common issues
- Cross-link related concepts throughout
- Keep focus on agent enablement (not just reference docs)

### Quality Criteria:
- Comprehensive API coverage
- Clear conceptual explanations
- Practical code examples
- Highlighted pitfalls/gotchas
- Testing guidance integrated
- Go-specific patterns included
- No migration content
- References to official docs
