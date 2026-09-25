# cncf-agentic-platform

> Building an Agentic Internal Developer Platform with CNCF projects on k3d.

Personal Platform Engineering lab demonstrating how to design, operate, and
observe an Internal Developer Platform (IDP) built **exclusively on CNCF
projects**, with a focus on **AI agents as first-class workloads**.

> **Disclaimer** — This is a personal project. It is not affiliated with,
> endorsed by, or sponsored by the CNCF, the Linux Foundation, or any of the
> projects it references.

## Goals

- Provision a local Kubernetes cluster with **k3d**.
- Bootstrap a GitOps-driven platform using **CNCF projects only**.
- Deliver observability, security, and networking as platform primitives.
- Run **AI agents** on Kubernetes (starting with **kagent**, CNCF Sandbox).
- Explore CNCF Sandbox projects related to agentic AI workloads.

## Status

🚧 Day 0 — repository scaffolding.

## Architecture (target)

```text
┌─────────────────────────────────────────────────────────────┐
│                        Developer                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                     GitOps (Argo CD)
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  k3d Kubernetes cluster                     │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │ Networking │  │ Security   │  │ Observ.    │             │
│  └────────────┘  └────────────┘  └────────────┘             │
│                                                             │
│  ┌────────────────────────────────────────────┐             │
│  │            AI Agent Runtime                │             │
│  │              (kagent)                      │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

Details will be added as the platform is built.

## Prerequisites

- Docker
- k3d
- kubectl
- helm
- argocd (CLI)

## Quickstart

```bash
make help
make bootstrap   # TODO
make cluster-up  # TODO
```

## Repository layout

| Path         | Purpose                                             |
| ------------ | --------------------------------------------------- |
| `bootstrap/` | Cluster and platform bootstrap scripts              |
| `clusters/`  | k3d cluster definitions (multi-cluster ready)       |
| `gitops/`    | GitOps manifests (Argo CD)                          |
| `platform/`  | Platform components (networking, security, observ.) |
| `agents/`    | AI agent definitions and workloads                  |
| `docs/`      | Documentation, ADRs, runbooks                       |

## Roadmap

- [x] Scaffold repository
- [x] Local k3d cluster up/down
- [x] GitOps bootstrap with Argo CD
- [ ] Observability stack
- [ ] Security baseline
- [ ] Networking baseline
- [ ] kagent deployment
- [ ] First agent use case
- [ ] Documentation and demos

## AI Transparency

This project is developed with AI assistance. All AI-generated content is
reviewed, tested, and validated by a human before commit. The author is
responsible for the final content.

## License

Code is licensed under the [Apache 2.0 license](LICENSE).

Documentation is licensed under a [CC-BY-4.0 license](LICENSE-docs).

This is a personal project and is not affiliated with CNCF or kagent.
