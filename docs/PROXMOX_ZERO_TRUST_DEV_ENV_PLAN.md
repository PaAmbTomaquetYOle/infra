# Proxmox Dev Environment Plan

## Goal

Stand up a development environment for the three repos on Proxmox, exposed externally through Cloudflare Zero Trust, and wired so CI/CD can keep it updated automatically.

This plan assumes:

- the three app repos remain separate
- shared infra lives in this `infra` repo
- shared project memory can later move to a new `knowledge-base` repo

## Recommended Repo Strategy

Keep the current app repos separate:

- `slack-agent`
- `backend`
- `mcp-server`

Use this repo for:

- `docker-compose.yml`
- `.env.example`
- deployment scripts
- Cloudflare tunnel config
- CI/CD deployment workflows

Create later:

- `braintrust-knowledge-base`
  - architecture docs
  - decisions
  - backlog summaries
  - operational runbooks

## Recommended Topology

### Preferred layout after the hackathon

Use 2 LXCs on Proxmox:

1. `braintrust-dev-docker`
   - Debian 12
   - Docker Engine
   - Docker Compose plugin
   - cloudflared
   - running the full dev stack
2. `braintrust-dev-runner`
   - Debian 12
   - GitHub Actions self-hosted runner
   - optional Docker client
   - triggers deployment into `braintrust-dev-docker`

### Current hackathon layout in use now

Use 1 LXC:

- `braintrust-dev`
  - Docker
  - cloudflared
  - GitHub Actions self-hosted runner

This is acceptable for the hackathon and is the current deployed shape.

## Services to Run in Docker

- `slack-agent`
- `backend`
- `mcp-server`
- `kafka`
- `kafka-ui`
- `postgres`
- `neo4j`

Internal-only services:

- Kafka
- Postgres
- Neo4j

Externally accessible only through Cloudflare Zero Trust:

- `kafka-ui`
- backend API/docs if needed
- `mcp-server`
- optional Neo4j browser

## Cloudflare Zero Trust Design

Use one Cloudflare Tunnel running inside the LXC.

Suggested hostnames:

- `braintrust-kafka.<your-domain>` -> `http://localhost:8080`
- `braintrust-api.<your-domain>` -> `http://localhost:8001`
- `braintrust-mcp.<your-domain>` -> `http://localhost:8000`
- `braintrust-neo4j.<your-domain>` -> `http://localhost:7474`

Protect them with Cloudflare Access policies:

- allow only project emails
- require login
- do not expose anonymous public access

## CI/CD Design

### CI responsibilities per app repo

- `slack-agent`: install, build, test, optional image build
- `backend`: install, lint, test, optional image build
- `mcp-server`: install, lint, test, optional image build

### CD responsibilities in this repo

This repo is the deployment controller:

1. check out the three app repos beside `infra`
2. own the deployment workflow
3. run on the self-hosted runner inside the LXC
4. execute `docker compose up -d --build`
5. run smoke checks

### Recommended artifact flow

- Hackathon path now:
  - app repos run their own CI
  - this repo checks out all repos on the runner
  - this repo rebuilds and restarts the stack in place
- Better post-hackathon path:
  - app repos build Docker images
  - app repos push images to GHCR
  - this repo references those images by tag
  - this repo deploys them

Suggested image names:

- `ghcr.io/<org>/braintrust-slack-agent`
- `ghcr.io/<org>/braintrust-backend`
- `ghcr.io/<org>/braintrust-mcp-server`

## Secrets and Environment

Keep runtime secrets in a non-committed `.env` file on the LXC, for example:

- `/opt/braintrust/infra/.env`

Include:

- Slack credentials
- Gemini key
- backend JWT secrets
- Postgres credentials
- Neo4j credentials
- Jira/Trello OAuth credentials
- Cloudflare tunnel token if tunnel is managed locally

## Current Validation Status

Current single-LXC state already achieved:

- Docker stack runs successfully
- `backend` health passes
- `mcp-server` health passes
- `slack-agent` health passes in dry-run mode
- GitHub Actions self-hosted runner is installed and listening for jobs
- `infra/docker-compose.yml` has been moved into its own repo

## Recommended Next Steps

1. Commit this repo structure
2. Add the `ORG_REPO_READ_TOKEN` secret in the infra repo
3. Push and enable the deploy workflow in this repo
4. Finish Cloudflare tunnel config and Access policies
5. Later, move from local build contexts to GHCR image references
