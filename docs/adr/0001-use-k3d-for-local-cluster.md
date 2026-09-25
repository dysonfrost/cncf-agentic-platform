---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [kubernetes, local-dev, tooling]
---

# 0001. Use k3d for local Kubernetes

## Context and Problem Statement

Need a local Kubernetes cluster that is disposable, portable across macOS and
Linux, supports multi-node for scheduling experiments, and fits in an 8 GiB
dev laptop.

## Considered Options

- k3d (k3s in Docker)
- minikube
- kind
- k3s installed on host

## Decision Outcome

Chosen option: "k3d", because it is disposable, supports multi-node and
multi-cluster on the same host, is portable across macOS and Linux, and fits
in a bounded memory budget. minikube is heavier and multi-node is awkward;
kind makes multi-cluster verbose; k3s on host requires host-level install and
cleanup.

### Consequences

- Good, because cluster lifecycle is a single command in both directions.
- Good, because multi-node and multi-cluster topologies are first-class.
- Bad, because nodes are Docker containers on one host: fine for scheduling
  and rollout tests, not for network isolation.
- Bad, because cloud features (LoadBalancer IPs, CSI) are emulated.
- Bad, because k3d memory limits are fake meminfo, not real Docker limits.

### Confirmation

Single-command lifecycle on both macOS and Linux: cluster creation, multi-node
readiness, and cleanup leave no containers or volumes behind. See `make help`
for the current entry points.
