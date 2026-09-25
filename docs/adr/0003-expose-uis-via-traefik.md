---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [networking, ingress]
---

# 0003. Expose platform UIs via Traefik and .localhost hostnames

## Context and Problem Statement

Platform services with a web UI (Argo CD, Grafana, Prometheus) need stable
URLs. Port-forwarding does not scale. Public DNS (`nip.io`, `sslip.io`) adds
an external dependency, `*.k8s.orb.local` is not portable, `.local` conflicts
with mDNS (RFC 6762), and `.lan` requires a local DNS server.

## Considered Options

- Port-forward per service
- `*.localhost` hostnames with Traefik
- `/etc/hosts` entries via a Makefile target

## Decision Outcome

Chosen option: "`*.localhost` hostnames with Traefik", because Traefik is
already installed by k3s and exposed via the k3d load balancer (ADR 0001),
and `.localhost` is a Special-Use Domain Name (RFC 6761) that resolvers
must map to loopback addresses.

### Consequences

- Good, because UIs are reachable at stable URLs without port-forwarding.
- Good, because no external DNS dependency and no `/etc/hosts` edits.
- Bad, because Chrome and Firefox resolve `*.localhost` natively, but Safari
  and CLI tools do not; `--resolve` is required.
- Bad, because Traefik is not a long-term choice; migration to Gateway API
  will be its own ADR.

### Confirmation

`curl --resolve argocd.localhost:8080:127.0.0.1 -s -o /dev/null -w "%{http_code}"
http://argocd.localhost:8080` returns 200.
