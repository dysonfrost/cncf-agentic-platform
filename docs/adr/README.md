# Architecture Decision Records

This directory holds ADRs for `cncf-agentic-platform`. Format: [MADR 4.0](https://adr.github.io/madr/).

Each ADR is a single Markdown file with YAML front-matter. Files are numbered
four-digit-zero-padded and never renumbered. Superseded ADRs are kept and linked.

## Format

MADR 4.0, minimal template, with front-matter and Confirmation section added.
See `template.md`.

## Index

| #                                         | Status   | Title                                                    |
| ----------------------------------------- | -------- | -------------------------------------------------------- |
| [0001](0001-use-k3d-for-local-cluster.md) | Accepted | Use k3d for local Kubernetes                             |
| [0002](0002-use-argo-cd-for-gitops.md)    | Accepted | Use Argo CD for GitOps                                   |
| [0003](0003-expose-uis-via-traefik.md)    | Accepted | Expose platform UIs via Traefik                          |
| [0004](0004-multi-source-applications.md) | Accepted | Use multi-source Applications                            |
| [0005](0005-observability-scope.md)       | Accepted | Start observability with kube-prometheus-stack only      |
| [0006](0006-separate-crds-application.md) | Accepted | Deploy CRD-heavy charts via a dedicated CRDs Application |
