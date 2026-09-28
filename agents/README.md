# Agents

kagent CRDs deployed via the `kagent-agents` Argo CD Application, defined
in `gitops/argocd-apps/platform/kagent-agents.yaml`. The Application points
to this directory.

See ADR 0007 for the runtime choice, ADR 0009 for the Substrate deferral,
and ADR 0010 for the orchestration pattern.

Agents use the `Agent` CRD in `v1alpha2` (compatibility API). Substrate and
`SandboxAgent` (`v1alpha3`) are deferred (ADR 0009).

## Current agents

```text
incident-investigator (orchestrator)
├── cluster-health    (inventory: nodes, pods, resources)
└── log-analyzer      (pod log analysis)
```

Each sub-agent has an `a2aConfig` exposing its skills. The orchestrator
declares them as tools with `isolateSessions: true` for fan-out.

## Structure

An Agent CRD has four parts:

- **`modelConfig`**: points to `ollama-qwen3`, which targets
  `http://host.k3d.internal:11434` (ADR 0008). Ollama must be running on
  the host for agents to respond.
- **`systemMessage`**: the agent's role and instructions
- **`tools`**: MCP servers (`kagent-tool-server`) or other agents
- **`a2aConfig`**: skills exposed to other agents over A2A

## Files

| File                         | Agent                  |
| ---------------------------- | ---------------------- |
| `model-config.yaml`          | ModelConfig for Ollama |
| `cluster-health.yaml`        | cluster-health         |
| `log-analyzer.yaml`          | log-analyzer           |
| `incident-investigator.yaml` | incident-investigator  |

## Adding an agent

1. Create `<name>.yaml` in this directory.
2. Reference `modelConfig: ollama-qwen3`.
3. Add a `tools` list with the MCP tools it needs.
4. Add an `a2aConfig.skills` entry if other agents should discover it.
5. Commit and push; Argo CD syncs automatically.

## Verify

```bash
kubectl -n kagent get agents
kubectl -n kagent get modelconfigs
```
