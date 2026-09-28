---
status: Accepted
date: 2026-09-28
deciders: dysonfrost
tags: [agents, observability, kagent, tempo]
---

# 0011. Observe kagent with metrics and traces

## Context and Problem Statement

ADR 0005 covered platform observability with kube-prometheus-stack. kagent
now runs three agents (ADR 0007, 0010) but is not observed. Agent-level
visibility (tool calls, arguments, A2A hop ordering) requires OTLP traces,
which Prometheus cannot provide.

## Considered Options

- Infrastructure metrics only (Prometheus + Grafana)
- Infrastructure metrics + OTLP traces (Tempo + OTel Collector)
- Full OTLP (metrics + traces + logs): rejected, logs would require Loki
  (~1 GiB) and are not justified for the current scope

## Decision Outcome

Chosen option: "infrastructure metrics + OTLP traces", because per-request
debugging of A2A workflows requires trace-level visibility that metrics
cannot provide.

The chart's native ServiceMonitor is enabled for kagent metrics. Tempo is
deployed in monolithic mode, with an OTel Collector receiving OTLP from
kagent and forwarding to Tempo. Grafana uses Tempo as a datasource.

### Consequences

- Good, because per-request traces show tool call sequences, arguments, and
  A2A hop ordering.
- Good, because Tempo monolithic mode does not require Kafka.
- Bad, because Tempo and the OTel Collector add significant memory
  (~2-8 GiB depending on trace volume and retention).
- Bad, because Tempo monolithic mode is not recommended for production use.
- Bad, because Tempo uses local storage; production would require object
  storage.

### Confirmation

`kubectl -n kagent get servicemonitor` lists a ServiceMonitor. Prometheus
`/targets` shows the kagent controller as `up`. Tempo contains traces for
agent requests, visible in Grafana's Explore view.
