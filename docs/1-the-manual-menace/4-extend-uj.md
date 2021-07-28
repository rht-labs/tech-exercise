## Extend UJ with a another tool, eg Nexus 
- (emphasize IF IT'S NOT GIT, IT'S NOT REAL!!! mantra)

Add more tools to the UJ for ex, nexus for managing our artifacts

update your `ubiquitous-journey/values-tooling.yaml` to include Nexus with some sensible defaults 
```yaml
  # Nexus
  - name: nexus
    enabled: true
    source: https://redhat-cop.github.io/helm-charts
    chart_name: sonatype-nexus
    source_ref: "0.0.15"
    values:
      service:
        name: nexus
```

```bash
git add, commit, push..
```

observe ArgoCD that nexus spins up and connect to Nexus itself to verify
