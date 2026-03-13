#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT_DIR/scripts/preflight-guard.sh" core

cat <<'MSG'
[core] Running minimal secure baseline for NEW VPS:
- system update
- non-root user + ssh key setup
- ssh hardening
- firewall base
- fail2ban

This wrapper launches upstream interactive flow (vpskit.sh).
Choose only baseline/security setup steps.
MSG

exec bash "$ROOT_DIR/vpskit.sh"
