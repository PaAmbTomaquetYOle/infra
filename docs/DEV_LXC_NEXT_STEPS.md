# Dev LXC Next Steps

This is the concrete follow-up for the current single-LXC setup at `172.16.0.172`.

## Current State

- Docker is installed
- Docker Compose is installed
- the app stack is already running from `/opt/braintrust/infra`
- the GitHub Actions self-hosted runner is installed and active
- a Cloudflare tunnel container has already been started

## What To Do Next

1. Keep the four repos merged to `main`.
2. Keep the self-hosted runner service active on the LXC.
3. On the LXC, create or keep the runtime env file:
   - `/opt/braintrust/infra/.env`
4. Configure the Cloudflare tunnel ingress rules so each hostname points to the matching Docker Compose service.
5. Trigger the deploy workflow manually when a full rebuild is needed.

## Required Cloudflare Mapping

- `braintrust-api.<domain>` -> `http://backend:8888`
- `braintrust-mcp.<domain>` -> `http://mcp-server:8000`
- `braintrust-kafka.<domain>` -> `http://kafka-ui:8080`
- `braintrust-neo4j.<domain>` -> `http://neo4j:7474`

Use HTTP for these Cloudflare service mappings. Keep Slack agent internal while Slack Socket Mode is enabled.

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
timeout 2 bash -c '</dev/tcp/127.0.0.1/8000' && echo mcp-port-ok
curl http://localhost:8001/api/v1/health
```

## Post-Hackathon Hardening

- move app image builds to GHCR
- pin image tags in `infra/docker-compose.yml`
- split runner and app runtime into separate LXCs
- back up persistent volumes for Postgres and Neo4j
