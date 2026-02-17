#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TILE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$TILE_DIR/test-output/terraform-provider-petstore"
CONTAINER_NAME="petstore-tile-test"
PETSTORE_PORT=18080
PETSTORE_URL="http://localhost:${PETSTORE_PORT}/api"

echo "=== Tile Validation ==="
echo "Tile:   $TILE_DIR"
echo "Output: $TEST_DIR"
echo "API:    $PETSTORE_URL"
echo ""

# Clean previous run
rm -rf "$TILE_DIR/test-output"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Start local Petstore API
echo "=== Starting local Petstore API ==="
docker run -d --name "$CONTAINER_NAME" -p "${PETSTORE_PORT}:8080" swaggerapi/petstore
echo "Waiting for Petstore API..."
for i in $(seq 1 30); do
  if curl -sf "http://localhost:${PETSTORE_PORT}/" >/dev/null 2>&1; then
    echo "Petstore API ready"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "ERROR: Petstore API failed to start"
    docker logs "$CONTAINER_NAME"
    exit 1
  fi
  sleep 1
done

# Cleanup on exit
cleanup() {
  echo ""
  echo "=== Cleaning up ==="
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

# Download HashiCorp scaffold template
echo "=== Downloading scaffold template ==="
mkdir -p "$TILE_DIR/test-output"
curl -sL https://github.com/hashicorp/terraform-provider-scaffolding-framework/archive/refs/heads/main.tar.gz | \
  tar xz -C "$TILE_DIR/test-output/"
mv "$TILE_DIR/test-output/terraform-provider-scaffolding-framework-main" "$TEST_DIR"

# Resolve Go dependencies so tessl can detect them
echo "=== Resolving Go dependencies ==="
cd "$TEST_DIR"
go mod tidy

# Install our tile under test (local)
echo "=== Installing tile under test ==="
tessl install "file:$TILE_DIR"

# Auto-install registry tiles for project dependencies (testify, framework, etc.)
echo "=== Installing dependency tiles ==="
tessl install --project-dependencies --yes

LOGFILE="$TILE_DIR/test-output/claude-output.jsonl"

# Export endpoint for acceptance tests
export PETSTORE_ENDPOINT="$PETSTORE_URL"

echo ""
echo "=== Running Claude ==="
echo "Log: $LOGFILE"
PROMPT="$(cat "$SCRIPT_DIR/prompt.md")"
PROMPT="${PROMPT//\{\{PETSTORE_URL\}\}/$PETSTORE_URL}"
claude -p "$PROMPT" \
  --allowedTools "Read,Edit,Write,Bash,Glob,Grep" \
  --output-format stream-json \
  --verbose \
  | tee "$LOGFILE" \
  | python3 -u "$SCRIPT_DIR/stream_output.py"

echo ""
echo "=== Validating output ==="

echo "--- go build ---"
go build ./...
echo "PASS"

echo "--- go vet ---"
go vet ./...
echo "PASS"

echo "--- go test ---"
TF_ACC=1 go test ./... -count=1 -timeout 180s
echo "PASS"

echo ""
echo "=== Validation complete ==="
