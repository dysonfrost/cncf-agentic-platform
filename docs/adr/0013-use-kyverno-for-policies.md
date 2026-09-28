---
status: Accepted
date: 2026-09-28
deciders: dysonfrost
tags: [security, kyverno, policies]
---

# 0013. Use Kyverno for admission policies

## Context and Problem Statement

The platform has no admission control: any workload can be deployed without
validation. A policy engine would let us enforce baselines, including on
workloads created by agents (ADR 0007).

## Considered Options

- Kyverno (Kubernetes-native, YAML/CEL policies)
- OPA Gatekeeper (Rego policies)
- No admission controller (defer)

## Decision Outcome

Chosen option: "Kyverno", because it is CNCF Graduated and Kubernetes-native:
policies are YAML with CEL expressions, matching the rest of the project.
Gatekeeper requires Rego, a separate language.

Kyverno 1.19+ is used with CEL-based policy types (`ValidatingPolicy`),
since `ClusterPolicy` is deprecated and will be removed in v1.20.

Three policies are deployed:

1. `require-recommended-labels` (Deny): workloads must carry
   `app.kubernetes.io/name` and `app.kubernetes.io/instance`.
2. `disallow-latest-tag` (Deny): images must not use `latest`.
3. `require-run-as-non-root` (Audit): containers must set
   `securityContext.runAsNonRoot: true`.

CRDs come from the `kyverno-api` subchart. The Application sets
`ServerSideApply=true` (CRDs exceed 262 KB) and `ServerSideDiff=true` with
`IncludeMutationWebhook=true` (Kyverno mutates resources).

### Consequences

- Good, because policies are readable YAML/CEL, consistent with the project.
- Good, because the three policies cover image hygiene, workload identity,
  and container hardening.
- Bad, because Kyverno adds admission webhooks and a background controller
  (~300-500 MiB).
- Bad, because `ValidatingPolicy` (CEL) is newer and less documented than
  `ClusterPolicy`.

### Confirmation

`kubectl get validatingpolicies.policies.kyverno.io` lists the three
policies. `kubectl run test --image=nginx:latest` is rejected with a message
from `disallow-latest-tag`. Existing Helm workloads pass all three policies.
