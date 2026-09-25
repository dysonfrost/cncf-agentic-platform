---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [gitops, argocd, crds, observability]
---

# 0006. Deploy CRD-heavy charts via a dedicated CRDs Application

## Context and Problem Statement

ADR 0005 introduced `kube-prometheus-stack` for observability but did not
address how its embedded Prometheus Operator CRDs would be applied. Those
CRDs exceed the 262144-byte annotation limit, and the operator fails to
detect CRDs registered after its startup.

When Argo CD syncs the chart in a single Application, the operator starts
before the CRDs are available, and the `Prometheus` and `Alertmanager` CRs
stay unreconciled until a manual restart.

## Considered Options

- Single Application with `ServerSideApply=true` (bypasses the size limit
  but not the ordering problem)
- Dedicated CRDs Application with sync-waves
- Manual operator restart after bootstrap

## Decision Outcome

Chosen option: "dedicated CRDs Application with sync-waves": Argo CD applies
the CRDs Application first (wave `-1`), waits for `Synced / Healthy`, then
applies the chart Application (wave `0`). The operator sees the CRDs at
startup, no restart needed.

The CRDs Application uses `prometheus-operator-crds` matching the Prometheus
Operator version bundled in `kube-prometheus-stack` (app version, not chart
version), sets `ServerSideApply=true` for large CRDs, and `prune: false` to
prevent cascade deletion of custom resources. The chart Application disables
CRD management via `crds.enabled: false`.

The pattern applies to any future operator with CRDs (cert-manager, Kyverno,
kagent).

### Consequences

- Good, because the bootstrap is deterministic on a fresh cluster.
- Good, because the pattern generalizes to all operators with CRDs.
- Bad, because each operator now requires two Applications instead of one.
- Bad, because the CRDs chart version must track the Prometheus Operator
  version bundled in the main chart; chart versions differ (e.g. 32.x vs
  91.x) and must be reconciled by app version.

### Confirmation

On a fresh cluster, `make gitops-bootstrap` results in both
`prometheus-operator-crds` and `kube-prometheus-stack` in `Synced / Healthy`,
with `kubectl -n monitoring get prometheus,alertmanager` reporting
`RECONCILED: True` on both CRs, without any manual operator restart.
