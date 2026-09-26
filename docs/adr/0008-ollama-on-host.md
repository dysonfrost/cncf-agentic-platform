---
status: Accepted
date: 2026-09-27
deciders: dysonfrost
tags: [agents, ollama, llm]
---

# 0008. Run Ollama on the host for local LLM inference

## Context and Problem Statement

kagent (ADR 0007) requires an LLM backend. Options: Ollama in the cluster,
Ollama on the host, or a cloud API. The Linux workstation has an AMD RX
6700 XT (12 GiB VRAM) available for inference.

## Considered Options

- Ollama in the cluster, with GPU passthrough
- Ollama on the host, as a Docker container
- Cloud API (OpenAI, Anthropic, DeepSeek)

## Decision Outcome

Chosen option: "Ollama on the host as a Docker container", because:

- k3d does not support AMD GPU passthrough.
- gVisor (Agent Substrate, ADR 0007) does not support GPU access by design.
- A cloud API contradicts the project's local-first constraint.

Ollama runs as `ollama/ollama:rocm` with `HSA_OVERRIDE_GFX_VERSION=10.3.0`
(required for the RX 6700 XT). kagent accesses it via `host.k3d.internal:11434`.
The model is `qwen3:8b`, chosen for its function calling capabilities over
`llama3.1:8b`. Installation is scripted via `make ollama-install`.

### Consequences

- Good, because the full 12 GiB VRAM is available for inference.
- Good, because the same setup works on macOS (Metal) and Linux (ROCm).
- Good, because no cloud API dependency and no inference cost.
- Bad, because Ollama is not managed by Argo CD; it runs outside the cluster
  as a host-level Docker container.
- Bad, because qwen3:8b function calling is unreliable (~44% accuracy in
  some benchmarks); tool call failures must be handled in agent prompts.

### Confirmation

`curl http://localhost:11434/api/tags` returns the list of pulled models,
including `qwen3:8b`. The kagent `ModelConfig` references `qwen3:8b` and
points to `http://host.k3d.internal:11434`.
