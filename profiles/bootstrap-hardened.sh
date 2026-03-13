#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT_DIR/scripts/preflight-guard.sh" hardened

cat <<'MSG'
[hardened] Strict hardening mode (manual-confirm required):
- tighter firewall policy
- stricter SSH settings
- additional host checks

WARNING: run this only on a fresh or maintenance-window VPS.
This wrapper launches upstream interactive flow (vpskit.sh).
MSG

read -r -p "Type HARDEN to continue: " ACK
[[ "$ACK" == "HARDEN" ]] || { echo "Aborted"; exit 1; }

exec bash "$ROOT_DIR/vpskit.sh"
