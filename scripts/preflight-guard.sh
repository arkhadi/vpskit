#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-core}"

echo "[preflight] mode=$MODE"

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

echo "[ok] preflight passed"
