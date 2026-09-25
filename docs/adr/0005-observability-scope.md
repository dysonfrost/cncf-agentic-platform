---
status: Accepted
date: 2026-09-25
deciders: dysonfrost
tags: [observability, prometheus, grafana]
---

# 0005. Start observability with kube-prometheus-stack only

## Context and Problem Statement

The platform needs observability before AI agents can be deployed, and
Prometheus + Grafana will later be the data source for agent use cases
(cluster health summaries, crash diagnostics). A full stack (metrics, logs,
traces) would exceed the memory budget of the development laptop (ADR 0001).

## Considered Options

- kube-prometheus-stack (metrics, dashboards, alerting)
- kube-prometheus-stack + Loki (logs)
- kube-prometheus-stack + Loki + Tempo (traces)
- VictoriaMetrics stack

## Decision Outcome

Chosen option: "kube-prometheus-stack", because metrics are the minimum
viable observability layer for agent use cases, and the chart covers
Prometheus, Grafana, Alertmanager, node-exporter, and kube-state-metrics in
one component. Loki and Tempo are deferred until a concrete need appears and
the memory budget allows.

Chart version pinned. Deployed as a multi-source Application (ADR 0004).
Grafana exposed at `grafana.localhost:8080` via Traefik (ADR 0003).

### Consequences

- Good, because one component to integrate and operate.
- Good, because Prometheus + Grafana cover the agent use cases already
  planned.
- Bad, because logs and traces are unavailable until Loki and Tempo are
  added.
- Bad, because the chart requires tuned values to fit on the dev laptop;
  naive installs will not. Target ~2 GiB, to be measured.
- Bad, because the operator adds CRDs, admission webhooks, and ServiceMonitors
  to maintain.
- Bad, because adding Loki later will require its own ADR and a revision of
  the memory budget.

### Confirmation

Prometheus, Grafana, and Alertmanager pods are Running in the `monitoring`
namespace. Grafana is reachable at `grafana.localhost:8080` and shows cluster
metrics. A PromQL query such as `up{job="kubelet"}` returns results.
