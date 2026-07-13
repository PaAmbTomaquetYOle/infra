# Dev LXC Next Steps

This is the concrete follow-up for the current single-LXC setup at `172.16.0.172`.

## Current State

- Docker is installed
- Docker Compose is installed
- the app stack is already running from `/opt/braintrust/infra`
- the GitHub Actions self-hosted runner is installed and active
- a Cloudflare tunnel container has already been started

## What To Do Next

1. Push the `infra` repo and the `feat/hackathon-dev-stack` branch.
2. Add this repo secret in GitHub:
   - `ORG_REPO_READ_TOKEN`
   - scope: read access to `PaAmbTomaquetYOle/offboard-me`, `PaAmbTomaquetYOle/backend`, and `PaAmbTomaquetYOle/mcp-server`
3. In the `infra` repo, enable the workflow in `.github/workflows/deploy-dev.yml`.
4. Make sure the runner has a stable working root:
   - recommended path: `/opt/github-runner-work`
5. On the LXC, create or keep the runtime env file:
   - `/opt/braintrust/infra/.env`
6. Configure the Cloudflare tunnel ingress rules so each hostname points to the matching local service.
7. Trigger the deploy workflow manually once to validate checkout, build, and smoke checks.

## Required Cloudflare Mapping

- `braintrust-api.<domain>` -> `http://localhost:8001`
- `braintrust-mcp.<domain>` -> `http://localhost:8000`
- `braintrust-kafka.<domain>` -> `http://localhost:8080`
- `braintrust-neo4j.<domain>` -> `http://localhost:7474`

Keep Slack agent internal for now unless there is a clear external use case.

## Runtime Files On The LXC

- app checkout root: `/opt/braintrust`
- infra env file: `/opt/braintrust/infra/.env`
- optional cloudflared config: `/opt/braintrust/infra/cloudflared/config.yml`

## First Deploy Validation

After the workflow runs, validate:

```bash
cd /opt/braintrust/infra
docker compose ps
curl http://localhost:3000/health
curl http://localhost:8000/health
curl http://localhost:8001/health
```

## Post-Hackathon Hardening

- move app image builds to GHCR
- pin image tags in `infra/docker-compose.yml`
- split runner and app runtime into separate LXCs
- back up persistent volumes for Postgres and Neo4j
