#!/usr/bin/env bash
# Start a local Python HTTP server to serve update files.
# Keep this running while testing the autoUpdater in the v1 app.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="$PROJECT_DIR/update-server"

if [ ! -f "$SERVER_DIR/updates/latest.json" ]; then
  echo "ERROR: $SERVER_DIR/updates/latest.json not found."
  echo "       Run scripts/03-setup-server.sh first."
  exit 1
fi

cd "$SERVER_DIR"

echo ">>> Starting update server at http://localhost:8000"
echo ""
echo "    Endpoints:"
echo "      GET http://localhost:8000/updates/latest.json  ← autoUpdater feed"
echo "      GET http://localhost:8000/releases/latest.zip  ← v2 package ($(du -sh releases/latest.zip 2>/dev/null | cut -f1 || echo '?'))"
echo ""
echo "    Press Ctrl+C to stop."
echo ""

python3 -m http.server 8000
