# vpskit-fran fork notes

This fork adds guardrails and profile-driven usage for safer bootstrap in mixed environments.

## Goals
- Keep upstream vpskit power for **new VPS bootstrap**.
- Avoid accidental changes on an existing control-plane VPS (OpenClaw/Axis host).
- Provide profile-based entrypoints for predictable runs.

## Profiles
- `core`: minimum secure baseline (user, ssh hardening, fail2ban, firewall base).
- `apps`: Docker/Caddy/deploy helpers for workload VPS.
- `hardened`: stricter host hardening checklist (manual-confirmed).

## New scripts
- `profiles/bootstrap-core.sh`
- `profiles/bootstrap-apps.sh`
- `profiles/bootstrap-hardened.sh`
- `scripts/preflight-guard.sh`

## Safety policy
- Never run full bootstrap on an existing control-plane host.
- Require explicit confirmation before high-risk operations.
- Keep OpenClaw-specific ports/config untouched unless explicitly requested.
