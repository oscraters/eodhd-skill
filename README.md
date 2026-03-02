# eodhd-skill

Open source OpenClaw skill and Bash CLI wrapper for the public EODHD API.

## Status

The repository now includes:

- a Codex/OpenClaw skill definition in [SKILL.md](./SKILL.md)
- an MVP Bash CLI at [scripts/eodhd](./scripts/eodhd)
- smoke tests at [scripts/test-smoke.sh](./scripts/test-smoke.sh)
- implementation and security references in [references/](./references/)

## Security stance

- Prefer `EODHD_API_KEY` injected by OpenClaw secrets management.
- Do not store API keys in repo files or local artifacts.
- Mask `api_token` values in dry-run and verbose output.
- Keep the CLI stateless: no cache, no profile, no token store.

## Quick start

```bash
EODHD_API_KEY=***REDACTED*** ./scripts/eodhd --dry-run eod AAPL.US
./scripts/test-smoke.sh
```
