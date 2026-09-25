---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [gitops, argocd, tooling]
---

# 0002. Use Argo CD for GitOps

## Context and Problem Statement

The platform needs a GitOps engine to reconcile cluster state from Git.
This is a portfolio project: the engine must be presentable without extra
tooling. It runs on the same 8 GiB laptop as the k3d cluster (ADR 0001).

Candidates: Argo CD, Flux.

## Considered Options

- Argo CD
- Flux

## Decision Outcome

Chosen option: "Argo CD", because it ships a web UI out of the box, which
matters for demos, and its Application CRD maps cleanly to per-component
ownership. Flux is stronger in pure GitOps composition, but its lack of a
default UI makes it less suitable here.

Installed via Helm, version pinned. Bootstrap pattern: app-of-apps, Argo CD
manages itself.

### Consequences

- Good, because the UI makes the platform observable without extra tooling.
- Good, because Application CRDs are a natural unit for delegation.
- Bad, because Argo CD is more resource-hungry than Flux on an 8 GiB laptop.
- Bad, because App-of-Apps becomes necessary beyond a few Applications.

### Confirmation

The Argo CD UI shows the root Application in Synced state, and
`kubectl get applications -n argocd` lists at least one child Application.
