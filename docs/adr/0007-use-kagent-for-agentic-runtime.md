---
status: Accepted
date: 2026-09-27
deciders: dysonfrost
tags: [agents, kagent, cncf, observability]
---

# 0007. Use kagent as the agentic runtime

## Context and Problem Statement

The platform has observability (ADR 0005) and GitOps (ADR 0002). The next
milestone is running AI agents on Kubernetes for operational tasks (cluster
health summaries, incident diagnosis) and eventually A2A workflows.

## Considered Options

- kagent (Kubernetes-native, CRD-based, CNCF Sandbox)
- Custom agents (LangChain/LlamaIndex on Kubernetes)
- No agent runtime (defer)

## Decision Outcome

Chosen option: "kagent", because it is Kubernetes-native (agents as CRDs),
built for platform engineers, and a CNCF Sandbox project. It supports
declarative GitOps, MCP-based tools, A2A communication, and Prometheus
integration.

Implementation:
- Runtime: Substrate (SandboxAgent in `v1alpha3`). Idle agents are snapshotted
  to S3-compatible storage and restored from pre-warmed gVisor workers.
- LLM: Ollama on the host as a Docker container (ADR 0008), accessed via
  `host.k3d.internal:11434`. Model: `qwen3:8b`.
- CRDs: separate `kagent-crds` Application in wave -1 (ADR 0006 pattern).
- First agent: cluster health summary querying Prometheus.

Chart versions for `kagent` and `kagent-crds` are pinned to the same tag.

### Consequences

- Good, because agents follow the same GitOps workflow as other components.
- Good, because Substrate avoids idle pod overhead for bursty workloads.
- Good, because kagent is CNCF Sandbox and supports MCP and A2A, aligning
  with the project's CNCF-only constraint.
- Bad, because kagent is Sandbox; the active API is `kagent.dev/v1alpha3`
  and may change between releases.
- Bad, because Substrate requires S3-compatible storage, adding MinIO or
  equivalent to the cluster.
- Bad, because the SandboxAgent API has no stable pod-per-agent alternative
  in `v1alpha3`; migration between API versions may be disruptive.

### Confirmation

`kubectl -n kagent get sandboxagents` lists at least one agent in `Ready`
state. The cluster health agent returns a natural-language summary derived
from Prometheus queries.
