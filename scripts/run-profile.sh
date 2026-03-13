#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="core"
CONFIG_FILE=""
NON_INTERACTIVE="false"
DRY_RUN="false"
ALLOW_SSH_CHANGES="${ALLOW_SSH_CHANGES:-false}"
ALLOW_FIREWALL_CHANGES="${ALLOW_FIREWALL_CHANGES:-false}"

usage() {
  cat <<EOF
Usage: bash scripts/run-profile.sh --profile <core|apps|hardened> [options]

Options:
  --config <file>           Load env-style config (KEY=VALUE)
  --non-interactive         Planned mode; validates config and runs wrappers without prompts where possible
  --dry-run                 Run preflight only, no changes
  --allow-ssh-changes       Allow modifications to existing SSH config
  --allow-firewall-changes  Allow modifications to existing active firewall config
  -h, --help                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --config) CONFIG_FILE="$2"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE="true"; shift ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --allow-ssh-changes) ALLOW_SSH_CHANGES="true"; shift ;;
    --allow-firewall-changes) ALLOW_FIREWALL_CHANGES="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -n "$CONFIG_FILE" ]]; then
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
  fi
  # shellcheck disable=SC1090
  set -a; source "$CONFIG_FILE"; set +a
fi

export ALLOW_SSH_CHANGES ALLOW_FIREWALL_CHANGES DRY_RUN

echo "[run-profile] profile=$PROFILE non_interactive=$NON_INTERACTIVE dry_run=$DRY_RUN"

if [[ "$NON_INTERACTIVE" == "true" ]]; then
  export VPSKIT_NON_INTERACTIVE=1
  echo "[warn] Upstream vpskit is mostly interactive; non-interactive support is best-effort in this fork wrappers."
fi

case "$PROFILE" in
  core) exec bash "$ROOT_DIR/profiles/bootstrap-core.sh" ;;
  apps) exec bash "$ROOT_DIR/profiles/bootstrap-apps.sh" ;;
  hardened) exec bash "$ROOT_DIR/profiles/bootstrap-hardened.sh" ;;
  *) echo "Invalid profile: $PROFILE"; usage; exit 1 ;;
esac
