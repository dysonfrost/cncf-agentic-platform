---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [gitops, argocd]
---

# 0004. Use multi-source Applications for external Helm charts

## Context and Problem Statement

`argocd-self` currently inlines its Helm values in the Application manifest,
duplicating `bootstrap/argocd/values.yaml`. Every change must be applied
twice, and the two copies will drift. The problem will get worse with the
observability stack, where values files run to hundreds of lines.

## Considered Options

- Inline values in the Application manifest
- Multi-source Application (chart + values from Git)
- Fork the upstream chart with values bundled

## Decision Outcome

Chosen option: "multi-source Application", because Argo CD supports
`sources` (plural) since v2.6, with one source pointing at the upstream Helm
chart and another source (aliased via `ref: values`) pointing at this
repository. `$values` resolves to the root of the referenced repository.

Subsequent Applications follow the same pattern.

### Consequences

- Good, because values files are the single source of truth, shared between
  `helm install` at bootstrap and Argo CD at runtime.
- Good, because Application manifests stay short even for large charts.
- Bad, because `sources` (plural) is marked beta; the UI and CLI only expose
  the first source, which limits interactive debugging.
- Bad, because `source` (singular) is ignored when `sources` is present, so
  the migration must be done in one step.
- Bad, because `$values` adds one indirection that readers must learn.

### Confirmation

`kubectl -n argocd get application argocd-self -o jsonpath='{.status.sync.status}'`
returns `Synced` after the refactor. Editing `bootstrap/argocd/values.yaml`
followed by a push and refresh produces a new sync.
