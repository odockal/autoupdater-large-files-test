#!/usr/bin/env bash
# Copy the v2 zip into update-server/ and generate the update manifest JSON.
# Must be run after scripts/02-build-v2.sh completes successfully.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="$PROJECT_DIR/update-server"
cd "$PROJECT_DIR"

echo ">>> Looking for v2 zip in out/make/…"
V2_ZIP=$(find out/make -maxdepth 2 -name "*.zip" | head -1)

if [ -z "$V2_ZIP" ]; then
  echo "ERROR: No zip found in out/make/. Run scripts/02-build-v2.sh first."
  exit 1
fi

echo "    Found: $V2_ZIP ($(du -sh "$V2_ZIP" | cut -f1))"

echo ""
echo ">>> Copying to update-server/releases/latest.zip…"
mkdir -p "$SERVER_DIR/releases" "$SERVER_DIR/updates"
cp "$V2_ZIP" "$SERVER_DIR/releases/latest.zip"
echo "    Copied: $(du -sh "$SERVER_DIR/releases/latest.zip" | cut -f1)"

echo ""
echo ">>> Writing update-server/updates/latest.json…"
cat > "$SERVER_DIR/updates/latest.json" <<EOF
{
  "url": "http://localhost:8000/releases/latest.zip",
  "name": "2.0.0",
  "notes": "Version 2.0.0 with large payload — macOS autoUpdater crash reproduction.",
  "pub_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo ""
echo ">>> Server ready at: $SERVER_DIR"
echo "    Manifest:  updates/latest.json"
cat "$SERVER_DIR/updates/latest.json"
echo ""
echo ">>> Next: run scripts/04-start-server.sh (in a separate terminal)"
echo "    Then install and launch the v1 app, and click 'Check for Updates'."
