---
status: Accepted
date: 2026-09-28
deciders: dysonfrost
tags: [agents, kagent, orchestration]
---

# 0010. Use supervisor fan-out for multi-agent orchestration

## Context and Problem Statement

kagent is operational with a single agent (ADR 0007), and A2A is supported
natively via `KAgentRemoteA2ATool`. The next step is orchestrating multiple
agents to answer questions that require different kinds of analysis, such as
"Why is my cluster slow?" which needs both cluster state and log inspection.

## Considered Options

- Supervisor with fan-out (parallel sub-agent calls, aggregated)
- Pipeline: rejected because the checks are independent, not sequential
- Hierarchical: rejected because one level of delegation is sufficient
- Swarm: rejected because the absence of a central coordinator makes
  synthesis harder

## Decision Outcome

Chosen option: "supervisor with fan-out", because the target use case
(cluster diagnostics) decomposes into independent checks that benefit from
parallel execution. The supervisor receives the question, dispatches to
sub-agents, and synthesizes their responses.

The pattern is implemented with `Agent` (v1alpha2), consistent with ADR 0009.

Fan-out is triggered by the LLM emitting multiple tool calls in a single
turn; the ADK runtime executes them concurrently. Sub-agent calls use
isolated sessions (`isolateSessions: true`) to prevent context corruption
when the same sub-agent is called multiple times in one fan-out.

### Consequences

- Good, because latency is bounded by the slowest sub-agent, not the sum.
- Good, because each sub-agent has a narrow toolset and clear responsibility.
- Bad, because partial failures require explicit handling; the supervisor
  must synthesize a degraded answer if one sub-agent fails.
- Bad, because aggregation quality depends on the supervisor model's ability
  to combine heterogeneous sources.

### Confirmation

`kubectl -n kagent get agents` lists `incident-investigator` in `Ready`
state, with `cluster-health` and `log-analyzer` declared as remote A2A tools.
A question like "Why is my cluster slow?" triggers parallel calls to both
sub-agents, visible in their respective logs.
