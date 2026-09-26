---
status: Accepted
date: 2026-09-27
deciders: dysonfrost
tags: [agents, kagent, substrate]
---

# 0009. Defer Agent Substrate for kagent

## Context and Problem Statement

ADR 0007 selected kagent with Substrate as the agent runtime (SandboxAgent
in `v1alpha3`). In practice, the kagent + Ollama + MCP tool chain was
validated first using `Agent` in `v1alpha2` without Substrate. Substrate
adds significant operational complexity: a separate `ate-system` namespace,
RustFS for S3-compatible snapshot storage, gVisor workers, and a Valkey
cluster.

## Considered Options

- Activate Substrate now
- Defer Substrate until A2A and multi-agent workflows are validated
- Abandon Substrate permanently

## Decision Outcome

Chosen option: "defer Substrate", because the core agentic capabilities
(kagent, MCP tools, Ollama inference, GitOps) are already operational and
demonstrable. Substrate's isolation and snapshots are valuable for
production, but not required for the current lab scope.

This ADR partially supersedes ADR 0007: the kagent choice stands, but the
Substrate runtime is deferred. kagent is deployed at v0.10.2, where `Agent`
in `v1alpha2` is still available alongside `SandboxAgent` in `v1alpha3`.

Substrate will be reconsidered when:

- A2A multi-agent workflows are in place.
- An agent needs to execute untrusted code.
- Resource constraints justify snapshot-based scale-to-zero.

### Consequences

- Good, because kagent is operational with minimal complexity.
- Good, because the validation of the core chain was not blocked by
  Substrate's setup.
- Bad, because `SandboxAgent` (v1alpha3) is not used; agents run with
  `Agent` (v1alpha2). Migrating to `SandboxAgent` will require rewriting
  agent definitions.
- Bad, because ADR 0007's implementation is only partial; Substrate-related
  consequences (RustFS, gVisor) remain theoretical.
- Bad, because `Agent` (v1alpha2) is a compatibility API and may be removed
  in a future kagent release.

### Confirmation

`kubectl -n kagent get agents` lists `cluster-health` in `Ready` state,
and the agent responds to natural-language queries. No `ate-system`
namespace exists.
