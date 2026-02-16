# Terraform Plugin Framework Tile - Task Checklist

**Last Updated**: 2026-02-16
**Status**: Not Started
**Type**: Documentation Creation

## Phase 1: Foundation & Core Concepts

- [ ] **Task 1.1**: Create document header and comprehensive table of contents
  - File: `docs/index.md:1-100`
  - Effort: S
  - Dependencies: None
  - Acceptance: TOC complete with all 12 major sections listed and linked

- [ ] **Task 1.2**: Write Overview & Quick Start section
  - File: `docs/index.md:101-350`
  - Effort: M
  - Dependencies: Task 1.1 (TOC structure defined)
  - Acceptance: Section includes what/when/installation/quick-start with code example

- [ ] **Task 1.3**: Write Provider Implementation section
  - File: `docs/index.md:351-650`
  - Effort: L
  - Dependencies: Task 1.2
  - Acceptance: Covers all provider interface methods with 4+ code examples

### Phase 1 Verification
- [ ] Read through all Phase 1 content for clarity
- [ ] Verify code examples compile (copy/paste test)
- [ ] Test internal TOC links work
- [ ] Confirm no TODOs remain in Phase 1 sections

---

## Phase 2: Resources & Data Sources

- [ ] **Task 2.1**: Write Resources section
  - File: `docs/index.md:651-1100`
  - Effort: L
  - Dependencies: Phase 1 complete
  - Acceptance: Documents CRUD operations, state management, import with 6+ examples

- [ ] **Task 2.2**: Write Data Sources section
  - File: `docs/index.md:1101-1350`
  - Effort: M
  - Dependencies: Task 2.1
  - Acceptance: Explains read-only nature, configuration vs computed, with examples

### Phase 2 Verification
- [ ] Verify CRUD examples are clear and complete
- [ ] Check data source examples compile
- [ ] Confirm pitfalls highlighted
- [ ] Validate cross-references to schema section work

---

## Phase 3: Schema & Type Systems

- [ ] **Task 3.1**: Write Schema System section
  - File: `docs/index.md:1351-1750`
  - Effort: L
  - Dependencies: Phase 2 complete
  - Acceptance: Documents all attribute types, nesting, blocks with 5+ examples

- [ ] **Task 3.2**: Write Type System section
  - File: `docs/index.md:1751-2050`
  - Effort: M
  - Dependencies: Task 3.1
  - Acceptance: Covers framework types, null/unknown, conversions with 4+ examples

### Phase 3 Verification
- [ ] Schema section explains all attribute types
- [ ] Nested attributes and blocks both covered
- [ ] Type conversions demonstrated clearly
- [ ] Null/unknown handling explained with examples

---

## Phase 4: Validators & Plan Modifiers

- [ ] **Task 4.1**: Write Validators section
  - File: `docs/index.md:2051-2350`
  - Effort: M
  - Dependencies: Phase 3 complete
  - Acceptance: Documents built-in validators, custom validators, cross-attribute with 5+ examples

- [ ] **Task 4.2**: Write Plan Modifiers section
  - File: `docs/index.md:2351-2650`
  - Effort: M
  - Dependencies: Task 4.1
  - Acceptance: Covers UseStateForUnknown, RequiresReplace, custom modifiers with 4+ examples

### Phase 4 Verification
- [ ] Validators section covers all common types
- [ ] Plan modifiers section explains common patterns
- [ ] UseStateForUnknown pattern emphasized (critical gotcha)
- [ ] Code examples are complete and correct

---

## Phase 5: Functions, Actions & Ephemeral Resources

- [ ] **Task 5.1**: Write Functions section
  - File: `docs/index.md:2651-2900`
  - Effort: M
  - Dependencies: Phase 4 complete
  - Acceptance: Documents function interface, parameters, returns with examples and HCL usage

- [ ] **Task 5.2**: Write Actions section
  - File: `docs/index.md:2901-3050`
  - Effort: S
  - Dependencies: Task 5.1
  - Acceptance: Covers basic action concepts and use cases

- [ ] **Task 5.3**: Write Ephemeral Resources section
  - File: `docs/index.md:3051-3200`
  - Effort: S
  - Dependencies: Task 5.2
  - Acceptance: Explains ephemeral lifecycle (Open/Close) with code example

### Phase 5 Verification
- [ ] Functions section explains provider functions clearly
- [ ] Function usage in Terraform HCL demonstrated
- [ ] Ephemeral resources section explains session-scoped nature
- [ ] Use cases clarified for each capability

---

## Phase 6: Testing & Best Practices

- [ ] **Task 6.1**: Write Testing Patterns section
  - File: `docs/index.md:3201-3600`
  - Effort: L
  - Dependencies: Phase 5 complete
  - Acceptance: Documents unit and acceptance testing with testify/require examples (4+)

- [ ] **Task 6.2**: Write Common Pitfalls & Best Practices section
  - File: `docs/index.md:3601-3900`
  - Effort: M
  - Dependencies: Task 6.1
  - Acceptance: Consolidates pitfalls from all sections, includes 10+ best practices

### Phase 6 Verification
- [ ] Unit test examples use testify/require (per go-dev-guidelines)
- [ ] Acceptance test examples use terraform-plugin-testing
- [ ] Test organization follows go-dev-guidelines (separate positive/negative)
- [ ] Go-dev-guidelines tile referenced appropriately
- [ ] Pitfalls from all areas consolidated

---

## Phase 7: Final Polish & Verification

- [ ] **Task 7.1**: Write Additional Resources section
  - File: `docs/index.md:3901-4000`
  - Effort: S
  - Dependencies: Phase 6 complete
  - Acceptance: Links to official docs, tutorials, community, related tiles

- [ ] **Task 7.2**: Comprehensive document review
  - File: `docs/index.md` (entire file)
  - Effort: M
  - Dependencies: Task 7.1
  - Acceptance: All verification checks pass (see detailed checklist below)

### Phase 7 Verification - Comprehensive Checklist

#### Content Completeness:
- [ ] All 12 major sections present and complete
- [ ] No TODO or placeholder text remains anywhere
- [ ] All phases 1-6 success criteria met
- [ ] At least 30 code examples included across all sections
- [ ] Common pitfalls highlighted in each major section
- [ ] Testing patterns integrated throughout

#### Code Quality:
- [ ] All code blocks use ```go syntax highlighting
- [ ] All code examples are syntactically valid Go
- [ ] Imports are correct and complete
- [ ] Examples follow go-dev-guidelines patterns where applicable
- [ ] Copy/paste 10-15 random examples into test file and verify compilation

#### Navigation & Links:
- [ ] Table of contents includes all 12 sections with subsections
- [ ] All internal TOC links work correctly (test each one)
- [ ] All external links are valid (no 404s):
  - [ ] developer.hashicorp.com links
  - [ ] github.com links
  - [ ] pkg.go.dev links
  - [ ] discuss.hashicorp.com links
- [ ] Cross-references between sections work correctly

#### Formatting & Style:
- [ ] Proper markdown header hierarchy (# → ## → ###)
- [ ] Lists formatted correctly (bullets, numbering)
- [ ] Code blocks properly opened and closed
- [ ] No broken formatting anywhere
- [ ] Consistent terminology throughout (e.g., "data source" not "datasource")
- [ ] Consistent code style in all examples
- [ ] Blockquotes used for warnings/tips
- [ ] Tables formatted correctly (if any)

#### Content Quality:
- [ ] Read entire document start to finish for flow
- [ ] Explanations are clear and agent-friendly
- [ ] Concepts flow logically from basic to advanced
- [ ] Examples support the explanations well
- [ ] "Why" explanations included, not just "how"
- [ ] Decision guidance provided (when to use what)

#### Framework Coverage:
- [ ] Provider implementation covered comprehensively
- [ ] Resources (CRUD) documented with all lifecycle methods
- [ ] Data sources explained clearly
- [ ] Schema system covers all attribute types and nesting
- [ ] Type system covers all framework types and conversions
- [ ] Validators (built-in and custom) documented
- [ ] Plan modifiers (especially UseStateForUnknown) covered
- [ ] Functions documented with HCL usage examples
- [ ] Actions covered (basic concepts)
- [ ] Ephemeral resources explained with lifecycle
- [ ] Testing patterns (unit and acceptance) included
- [ ] Common pitfalls consolidated from all areas

#### References & Integration:
- [ ] Go-dev-guidelines tile referenced appropriately (not over-referenced)
- [ ] External resources section complete with valid links
- [ ] Related tiles mentioned
- [ ] Community resources linked

#### Final Checks:
- [ ] Markdown renders correctly in viewer/renderer
- [ ] File size appropriate (~3000-4000 lines)
- [ ] Ready for agent consumption
- [ ] Search for "TODO" returns zero results
- [ ] Search for "FIXME" returns zero results
- [ ] No placeholder text like [description here] remains

---

## Final Verification

### Automated Checks:
N/A - Documentation task, no automated tests

### Manual Checks:
- [ ] Complete Phase 7 comprehensive checklist above
- [ ] Document renders correctly in markdown viewer
- [ ] All success criteria from all phases met
- [ ] Ready to publish as Tessl tile

## Implementation Notes

### Content Creation Tips:
- **Code examples**: Adapt from terraform-plugin-framework docs and scaffolding template
- **Pitfalls**: Draw from common issues in GitHub issues, Stack Overflow, HashiCorp forums
- **Testing patterns**: Follow go-dev-guidelines for testify/require and test organization
- **Cross-references**: Use markdown anchor links `[text](#section-name)`
- **External links**: Use full URLs for HashiCorp Developer and GitHub

### Time Estimates:
- Phase 1: ~3-4 hours
- Phase 2: ~4-5 hours
- Phase 3: ~4-5 hours
- Phase 4: ~3-4 hours
- Phase 5: ~2-3 hours
- Phase 6: ~4-5 hours
- Phase 7: ~2-3 hours
- **Total**: ~22-29 hours of focused documentation work

### Quality Standards:
- **Clarity**: Assume reader is learning terraform-plugin-framework for first time
- **Completeness**: Cover all major framework capabilities (comprehensive per user request)
- **Practicality**: Every concept has code example
- **Agent-Friendly**: Explain "why" and "when", not just "how"
- **Accuracy**: All information aligned with terraform-plugin-framework v1.17.0

### Resources to Reference:
- **Primary**: https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework
- **Secondary**: https://developer.hashicorp.com/terraform/plugin/framework
- **Examples**: https://github.com/hashicorp/terraform-provider-scaffolding-framework
- **Testing**: https://github.com/hashicorp/terraform-plugin-testing
- **Go Patterns**: go-dev-guidelines tile (for testing, TDD, conventions)

## Success Definition

The tile is complete and successful when:
1. ✅ All Phase 7 verification checks pass
2. ✅ An agent can read the docs and understand how to build a Terraform provider
3. ✅ Code examples are clear, accurate, and demonstrate best practices
4. ✅ Common pitfalls are highlighted to prevent mistakes
5. ✅ Testing guidance enables agents to write well-tested providers
6. ✅ Documentation is comprehensive (covers all APIs per user requirement)
7. ✅ No TODOs or placeholders remain
8. ✅ Ready for publication in Tessl registry
