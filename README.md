# eodhd-skill

Open source OpenClaw skill and Bash CLI wrapper for the public EODHD API.

## Status

The repository now includes:

- a Codex/OpenClaw skill definition in [SKILL.md](./SKILL.md)
- an MVP Bash CLI at [scripts/eodhd](./scripts/eodhd)
- smoke tests at [scripts/test-smoke.sh](./scripts/test-smoke.sh)
- implementation and security references in [references/](./references/)

## Current command coverage

The CLI currently exposes discovery plus documented REST families for:

- `services`, `docs`, `raw`
- `eod`, `real-time`, `live`, `live-v2`, `intraday`, `ticks`
- `dividends`, `splits`, `technical`, `fundamentals`, `bulk-last-day`
- `search`, `exchanges`, `exchange-symbols`
- `news`, `calendar`, `economic-events`, `macro-indicator`
- `screener`, `delisted`, `insider-transactions`

Use `./scripts/eodhd services` to inspect the current registry and doc links.

## Security stance

- Prefer `EODHD_API_KEY` injected by OpenClaw secrets management.
- Do not store API keys in repo files or local artifacts.
- Mask `api_token` values in dry-run and verbose output.
- Keep the CLI stateless: no cache, no profile, no token store.

## Quick start

```bash
EODHD_API_KEY=***REDACTED*** ./scripts/eodhd --dry-run eod AAPL.US
EODHD_API_KEY=***REDACTED*** ./scripts/eodhd services
EODHD_API_KEY=***REDACTED*** ./scripts/eodhd --dry-run macro-indicator USA --query indicator=gdp_current_usd
./scripts/test-smoke.sh
```
