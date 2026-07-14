#!/usr/bin/env bash
# Build v1.0.0 — small app, no large resource file.
# Run this first to produce the initial version the user will install.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo ">>> Installing dependencies…"
npm install

echo ""
echo ">>> Setting version to 1.0.0"
# Update version field in package.json without creating a git tag
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.version = '1.0.0';
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  console.log('package.json version set to 1.0.0');
"

echo ""
echo ">>> Building v1.0.0 (darwin/arm64, no large file)…"
npm run make -- --platform=darwin --arch=arm64

echo ""
echo ">>> Done. v1 artifacts:"
ls -lh out/make/*.zip 2>/dev/null || ls -lh out/make/
