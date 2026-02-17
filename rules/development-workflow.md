# Development Workflow

Build and test incrementally. Do NOT write all code before testing.

## Per-Resource Workflow

For each resource or data source, follow this cycle:

1. Write the resource/data source implementation
2. Write its acceptance test(s)
3. Run `go build ./...` to catch compilation errors
4. Run `TF_ACC=1 go test ./... -run TestAcc<Resource> -v -timeout 120s`
5. Fix any failures before moving to the next resource

Complete one resource end-to-end before starting the next.

## Build Verification

Run `go build ./...` after every file change. Do not accumulate unbuilt code.

## Test Failures

When a test fails:
- Read the full error output
- Fix the root cause (do not skip or delete the test)
- Re-run to confirm the fix
- Only then proceed to the next resource
