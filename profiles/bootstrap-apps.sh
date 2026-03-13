#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT_DIR/scripts/preflight-guard.sh" apps

cat <<'MSG'
[apps] Running app/workload setup mode:
- docker/caddy/deploy actions
- no full host re-bootstrap intended

This wrapper launches upstream interactive flow (vpskit.sh).
Use Deploy / Update / Rollback paths.
MSG

exec bash "$ROOT_DIR/vpskit.sh"
