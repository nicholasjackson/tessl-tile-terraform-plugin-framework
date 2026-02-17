# Research: Validating AI-Generated Code Against Specifications

## Problem Statement

Current validation (`validate.sh`) checks three things:
1. **`go build`** - code compiles
2. **`go vet`** - no obvious issues
3. **`TF_ACC=1 go test`** - acceptance tests pass

This proves the code works, but not that it's **complete or correct relative to the spec**. An agent could implement 2 of 10 API endpoints, write passing tests for just those 2, and validation would pass with flying colors.

## The Gap

| What we validate | What we don't validate |
|---|---|
| Code compiles | All spec endpoints have resources/data sources |
| Tests pass | Schema attributes match API model fields |
| CRUD operations work | All CRUD operations mapped correctly |
| Framework patterns followed | No hallucinated attributes or endpoints |

## Research Findings

### Approach 1: Programmatic Spec Coverage (Deterministic)

Parse the Swagger/OpenAPI spec with `jq` and compare against generated code.

**How it works:**
- Extract all paths from `swagger.json`
- Identify CRUD groups (POST+GET+PUT+DELETE on same resource = Terraform resource)
- Identify read-only endpoints (GET-only = data source candidates)
- Scan `provider.go` for `Resources()` and `DataSources()` registrations
- Compare and report coverage

**Strengths:** Fast, deterministic, no AI costs, catches missing resources entirely
**Weaknesses:** Can't verify attribute-level correctness, naming convention mismatches cause false negatives

**Tools:**
- `jq` for Swagger parsing (already available in bash)
- `libopenapi` (Go library by pb33f) for programmatic parsing
- `prance` (Python) for resolved spec access

### Approach 2: LLM-as-a-Judge with Binary Checklist

Use a second AI call to review the generated code against the spec using the CheckEval pattern (EMNLP 2025).

**How it works:**
1. Generate a checklist from the spec (deterministic): "Does resource X exist? Does it have attribute Y? Does Create call POST /path?"
2. Pass checklist + generated source to a judge LLM
3. Judge answers YES/NO per item with evidence (file:line)
4. Aggregate into coverage score

**Strengths:** Catches deep issues (wrong attributes, missing operations, incorrect API mappings)
**Weaknesses:** AI cost per evaluation, potential for judge errors, slower

**Best practices from research:**
- Binary scoring (pass/fail) >> Likert scales (1-10)
- Chain-of-thought reasoning improves accuracy
- Low temperature for consistency
- Structured JSON output for reliable parsing
- Evaluator can be less capable than generator (haiku can judge opus)

### Approach 3: Contract/Conformance Testing

Record HTTP calls during acceptance tests and compare against the Swagger spec.

**How it works:**
- Run tests through an HTTP proxy that captures all requests
- Compare captured requests against the Swagger spec
- Report which spec endpoints were exercised vs which were not

**Tools:** `swagger-coverage` (Java), `open-api-coverage` (PHP)
**Strengths:** Verifies actual API interaction, not just code structure
**Weaknesses:** Complex setup (proxy), only tests what tests exercise

### Approach 4: Tessl Eval Framework

Create `evals/` scenarios with task.md + rubric.json.

**How it works:**
- `task.md`: "Generate a Terraform provider for [API]"
- `rubric.json`: Weighted checklist scoring completeness, correctness, patterns
- `tessl eval run` executes with and without tile, compares scores
- A separate evaluator LLM grades against the rubric

**Strengths:** Integrates with tessl ecosystem, measures tile effectiveness
**Weaknesses:** Doesn't solve the general validation problem, specific to tile publishing

### Approach 5: HashiCorp's Code Generation Pipeline

HashiCorp provides `tfplugingen-openapi` which generates a Provider Code Specification from an OpenAPI spec. This intermediate representation could serve as a validation artifact.

**How it works:**
- Generate provider code spec from Swagger: `tfplugingen-openapi generate --config config.yml --output spec.json openapi.json`
- The config YAML explicitly maps OpenAPI paths to Terraform resources
- Compare the expected spec against actual generated code

**Strengths:** Official HashiCorp tooling, precise mapping
**Weaknesses:** Requires a generator config YAML (manual mapping), OpenAPI 3.x only (Petstore is Swagger 2)

### Industry Precedent: Cloudflare

Cloudflare auto-generates their Terraform provider from OpenAPI schemas. Key findings:
- Acceptance tests are the primary feedback loop
- ~15% of resources had issues even with programmatic generation
- Bugs at one layer hide bugs at other layers (schema errors mask API errors mask value check errors)
- **Layered validation is essential** - no single approach catches everything

## Recommended Layered Strategy

| Layer | What | How | Cost |
|---|---|---|---|
| 1. Spec coverage | All endpoints have resources | `jq` parse swagger + scan provider.go | Free, fast |
| 2. Attribute coverage | All model fields mapped | `jq` parse definitions + scan schema attrs | Free, fast |
| 3. Structural checks | CRUD methods, test files exist | `grep`/`go/ast` scan | Free, fast |
| 4. Acceptance tests | Operations actually work | `TF_ACC=1 go test` (existing) | Free, medium |
| 5. LLM judge | Deep correctness review | Second Claude call with binary checklist | ~$0.10-0.50 |
| 6. Tessl evals | Tile effectiveness over time | `tessl eval run` | Per tile publish |
