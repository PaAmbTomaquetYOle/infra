# BrainTrust Infra

This repo is the source of truth for the shared development and deployment environment around:

- `slack-agent`
- `offboard-me`
- `backend`
- `mcp-server`

It assumes those three repos stay separate and live as sibling directories during local development.

## Local Stack

The stack definition lives in `docker-compose.yml`.

### First-time setup

```bash
cp .env.example .env
docker compose up --build
```

PowerShell helpers:

```powershell
./scripts/stack-up.ps1 -Build
./scripts/smoke-check.ps1
```

## Included services

- `slack-agent`
- `offboard-me`
- `backend`
- `mcp-server`
- `kafka`
- `kafka-ui`
- `postgres`
- `neo4j`

## Important Notes

- `slack-agent` / `offboard-me` runs in `SLACK_AGENT_DRY_RUN=true` by default unless you replace the placeholder values in `.env`.
- `mcp-server` exposes a real MCP streamable HTTP endpoint at `http://localhost:8000/mcp`.
- This repo owns the shared deployment assets, not the application code.
- Cross-repo deployment workflow lives in `.github/workflows/deploy-dev.yml`.
- Private org repos will need an infra repo secret named `ORG_REPO_READ_TOKEN`.
- `cloudflared` should be managed by this Compose stack with `CLOUDFLARE_TUNNEL_TOKEN` set in `.env`.

## Proxmox and Zero Trust

Operational planning for the current single-LXC development environment lives in:

- `docs/PROXMOX_ZERO_TRUST_DEV_ENV_PLAN.md`
- `docs/DEV_LXC_NEXT_STEPS.md`

Cloudflare tunnel examples live in:

- `cloudflared/config.example.yml`
