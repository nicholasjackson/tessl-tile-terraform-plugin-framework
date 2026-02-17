# Plan: AI Output Validation for Terraform Provider Generation

## Objective

Add independent validation to `validate.sh` that verifies the generated Terraform provider covers the Swagger spec, beyond just "compiles and tests pass."

## Approach: Three Validation Layers

### Layer 1: Programmatic Spec Coverage Script (`test/check_coverage.py`)

A Python script (we already depend on Python for `stream_output.py`) that:

1. **Fetches the Swagger spec** from the running Petstore API
2. **Extracts expected resources** by grouping paths into CRUD clusters:
   - Paths with POST + GET-by-ID + PUT/PATCH + DELETE → expected Terraform resource
   - Paths with GET-by-ID only → expected data source
3. **Scans generated Go source** in `internal/provider/`:
   - Finds `provider.go` and extracts registered resource/data source type names
   - For each resource file, checks for Create/Read/Update/Delete method implementations
   - For each resource, checks for a corresponding `_test.go` file
   - Extracts schema attributes from resource files
4. **Compares spec fields against schema attributes**:
   - Maps Swagger model properties → expected Terraform attributes (camelCase → snake_case)
   - Reports missing/extra attributes per resource
5. **Outputs a structured report**:
   - Coverage percentage (resources, data sources, attributes)
   - Missing items with details
   - Exit code 0 if coverage meets threshold, 1 otherwise

**Integration:** Add to `validate.sh` after `go test`:
```bash
echo "--- spec coverage ---"
python3 "$SCRIPT_DIR/check_coverage.py" \
  --spec-url "$PETSTORE_URL/swagger.json" \
  --source-dir "$TEST_DIR/internal/provider" \
  --min-resource-coverage 80 \
  --min-attribute-coverage 70
```

### Layer 2: LLM-as-a-Judge Review (`test/judge_prompt.md`)

A second Claude call that reviews the generated code against the spec using binary checklist scoring.

1. **Generate checklist** from Swagger spec (done by the judge prompt):
   - For each resource: Does it exist? Does it have Create/Read/Update/Delete? Are attributes correct?
   - For each data source: Does it exist? Does it read correctly?
   - Framework patterns: diagnostics checks, state management, validators, plan modifiers

2. **Judge prompt template** (`test/judge_prompt.md`):
   ```
   You are reviewing a Terraform provider generated from a Swagger API spec.

   Spec: [fetched from API]
   Source: [read from generated files]

   For each item below, answer YES or NO with the file:line as evidence.
   Output as JSON: {"items": [{"check": "...", "pass": true/false, "evidence": "..."}]}

   Checklist:
   - [ ] Provider registers resource for each CRUD endpoint group
   - [ ] Each resource has all CRUD methods
   - [ ] Schema attributes cover all model fields
   - [ ] UseStateForUnknown on computed attributes
   - [ ] Diagnostics checked after all state operations
   - [ ] Acceptance tests for each resource and data source
   ...
   ```

3. **Integration:** Add to `validate.sh` after spec coverage:
   ```bash
   echo "--- AI review ---"
   claude -p "$(cat "$SCRIPT_DIR/judge_prompt.md")" \
     --allowedTools "Read,Glob,Grep,Bash" \
     --output-format json \
     | python3 "$SCRIPT_DIR/parse_judge.py"
   ```

### Layer 3: Tessl Evals (`evals/`)

Create evaluation scenarios for the tile itself:

```
evals/
  petstore-basic/
    task.md      # "Build a provider for the Petstore API"
    rubric.json  # Weighted checklist: resources, data sources, tests, patterns
  petstore-coverage/
    task.md      # "Build a provider covering ALL API endpoints"
    rubric.json  # Heavy weighting on completeness
```

**Rubric example:**
```json
{
  "context": "Terraform provider for Swagger Petstore API",
  "type": "weighted_checklist",
  "checklist": [
    {"name": "Pet resource implemented", "description": "petstore_pet resource with full CRUD", "max_score": 15},
    {"name": "Order resource implemented", "description": "petstore_order resource with CRUD", "max_score": 15},
    {"name": "User resource implemented", "description": "petstore_user resource with CRUD", "max_score": 15},
    {"name": "Pet data source", "description": "petstore_pet data source for lookup", "max_score": 10},
    {"name": "Order data source", "description": "petstore_order data source", "max_score": 10},
    {"name": "User data source", "description": "petstore_user data source", "max_score": 10},
    {"name": "Acceptance tests", "description": "All resources have TestAcc tests", "max_score": 15},
    {"name": "Framework patterns", "description": "Diagnostics, state management, validators", "max_score": 10}
  ]
}
```

## Implementation Order

1. **Layer 1 first** - `check_coverage.py` (deterministic, fast, free, highest value)
2. **Layer 3 next** - Tessl evals (integrates with existing ecosystem, needed for tile publishing)
3. **Layer 2 last** - LLM judge (most expensive, most thorough, can iterate on prompt)

## Files to Create/Modify

| File | Action | Purpose |
|---|---|---|
| `test/check_coverage.py` | Create | Programmatic spec-vs-code coverage checker |
| `test/validate.sh` | Modify | Add spec coverage step after tests |
| `test/judge_prompt.md` | Create | LLM-as-a-Judge review prompt |
| `test/parse_judge.py` | Create | Parse and display judge results |
| `evals/petstore-basic/task.md` | Create | Eval scenario task |
| `evals/petstore-basic/rubric.json` | Create | Eval scoring rubric |

## Success Criteria

- `check_coverage.py` reports >=80% resource coverage and >=70% attribute coverage
- LLM judge identifies no critical gaps (missing CRUD operations, wrong state management)
- `tessl eval run` shows measurable improvement with tile vs without
- Validation catches a deliberately incomplete provider (e.g., if we remove a resource from the prompt)

## Open Questions

1. Should the coverage thresholds be configurable or hard-coded?
2. Should the LLM judge run on every validation pass or only on demand (cost)?
3. Should we support OpenAPI 3.x specs as well as Swagger 2, or just match the test API?
4. For tessl evals, do we need a local Docker Petstore running, or can we use the public API?
