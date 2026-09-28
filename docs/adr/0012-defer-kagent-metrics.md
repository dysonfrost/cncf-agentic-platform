---
status: Accepted
date: 2026-09-28
deciders: dysonfrost
tags: [agents, observability, kagent]
---

# 0012. Defer kagent metrics until v1.0

## Context and Problem Statement

ADR 0011 selected "metrics + traces" for kagent observability. In practice,
kagent v0.10.2 does not expose a Prometheus `/metrics` endpoint on the
controller: the legacy runtime that provided it was removed in PR #2595,
and the OTel-based reader was reintroduced in PR #2929, four days after
the v0.10.2 release. A ServiceMonitor was deployed, but Prometheus received
HTTP 404 on `/metrics`.

## Considered Options

- Keep the ServiceMonitor (broken, returns 404)
- Remove the ServiceMonitor and defer metrics until kagent >= v1.0
- Upgrade kagent to v1.0.0-alpha4

## Decision Outcome

Chosen option: "remove the ServiceMonitor and defer metrics", because the
upgrade to v1.0.0-alpha4 introduces breaking changes (v1alpha3 API,
SandboxAgent-only runtime, new OTEL configuration keys) that exceed the
scope of an observability change. Traces, which work in v0.10.2, provide
the per-request visibility needed to debug A2A workflows.

Traces in v0.10.2 use kagent-specific OTEL flags (e.g.
`OTEL_TRACING_ENABLED`). These are removed in v1.0 in favor of SDK-spec
variables (`OTEL_TRACES_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`), which
will require a configuration update at upgrade time.

This ADR partially supersedes ADR 0011: traces remain, metrics are
deferred. Metrics will be reconsidered when kagent reaches a stable v1.0;
as of 2026-09-28 the v1.0 line is in alpha.

### Consequences

- Good, because the observability stack (Tempo + OTel Collector) has no
  broken components.
- Good, because traces cover the primary debugging use case.
- Bad, because controller-level metrics (gRPC latency, error rate,
  throughput) are unavailable.
- Bad, because upgrading kagent later will require reworking the agents
  (v1alpha2 → v1alpha3), the OTEL configuration, and possibly Substrate
  activation.
- Bad, because the `rpc_server_call_duration_seconds` metrics mentioned in
  ADR 0011 are not available until v1.0.

### Confirmation

`kubectl -n kagent get servicemonitor` returns no resources. Tempo contains
traces for agent invocations, visible in Grafana's Explore view with spans
for tool calls and A2A delegation.
