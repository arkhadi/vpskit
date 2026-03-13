#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-core}"
ALLOW_SSH_CHANGES="${ALLOW_SSH_CHANGES:-false}"
ALLOW_FIREWALL_CHANGES="${ALLOW_FIREWALL_CHANGES:-false}"
DRY_RUN="${DRY_RUN:-false}"

echo "[preflight] mode=$MODE dry_run=$DRY_RUN"

# Detect obvious control-plane indicators
HAS_OPENCLAW=0
if command -v openclaw >/dev/null 2>&1; then
  HAS_OPENCLAW=1
fi
if systemctl list-unit-files 2>/dev/null | grep -q openclaw-gateway; then
  HAS_OPENCLAW=1
fi

if [[ "$HAS_OPENCLAW" -eq 1 ]]; then
  echo "[warn] OpenClaw detected on this host."
  echo "[warn] This host looks like a control-plane VPS."
  echo "[warn] Do NOT run full bootstrap blindly here."
  if [[ "$MODE" != "apps" ]]; then
    echo "[block] mode '$MODE' blocked on control-plane host. Use mode=apps or run on a fresh VPS."
    exit 2
  fi
fi

# Guard against touching existing SSH unless explicitly allowed
if [[ "$MODE" != "apps" ]]; then
  if [[ -f /etc/ssh/sshd_config ]] && grep -Eq '^(PasswordAuthentication|PermitRootLogin)\s+' /etc/ssh/sshd_config 2>/dev/null; then
    if [[ "$ALLOW_SSH_CHANGES" != "true" ]]; then
      echo "[block] Existing SSH config detected. Set ALLOW_SSH_CHANGES=true to proceed with ssh modifications."
      exit 3
    fi
  fi

  # Guard against touching firewall unless explicitly allowed when already active
  if command -v ufw >/dev/null 2>&1; then
    UFW_STATE=$(ufw status 2>/dev/null | head -n1 || true)
    if echo "$UFW_STATE" | grep -qi 'active'; then
      if [[ "$ALLOW_FIREWALL_CHANGES" != "true" ]]; then
        echo "[block] UFW already active. Set ALLOW_FIREWALL_CHANGES=true to proceed with firewall changes."
        exit 4
      fi
    fi
  fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[dry-run] preflight passed. No changes applied."
  exit 0
fi

echo "[ok] preflight passed"
