#!/usr/bin/env bash
# Build v2.0.0 — includes a 1.1 GB dummy resource to make the installer > 1 GB.
# This is the update package that v1 will download, triggering the macOS crash.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

LARGE_FILE="resources/large-file.bin"
FILE_SIZE_MB=1126  # ~1.1 GB — adjust if you need a different size

echo ">>> Creating ${FILE_SIZE_MB} MB dummy file at ${LARGE_FILE}…"
mkdir -p resources
# /dev/zero is faster than /dev/urandom and sufficient for size testing
dd if=/dev/zero of="$LARGE_FILE" bs=1m count="$FILE_SIZE_MB" 2>&1
echo "    Created: $(du -sh "$LARGE_FILE" | cut -f1)"

echo ""
echo ">>> Setting version to 2.0.0"
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.version = '2.0.0';
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  console.log('package.json version set to 2.0.0');
"

echo ""
echo ">>> Building v2.0.0 (darwin/arm64, with large file via INCLUDE_LARGE_FILE=1)…"
INCLUDE_LARGE_FILE=1 npm run make -- --platform=darwin --arch=arm64

echo ""
echo ">>> Done. v2 artifacts:"
ls -lh out/make/*.zip 2>/dev/null || ls -lh out/make/
echo ""
echo "    Total size: $(du -sh out/make/)"
echo ""
echo ">>> Next: run scripts/03-setup-server.sh"
