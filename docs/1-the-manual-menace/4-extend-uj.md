## Extend UJ with a another tool, eg Nexus 
- (emphasize IF IT'S NOT GIT, IT'S NOT REAL!!! mantra)

Add more tools to the UJ for ex, nexus for managing our artifacts

ArgoCD has a cycle time of about 5ish mins - this is too slow for us, so we can make argocd sync our changes AS SOON AS things hit the git repo. Let's add a webhook to connect ArgoCD to our ubiquitous-journey project. 

![gitlab-argocd-webhook](images/gitlab-argocd-webhook.png)

* TODO - add docs & screeners for adding url to GitLab ...

Go to `tech-exercise` repo in UI (https://gitlab-ce.apps.<CLUSTER_DOMAIN>/<TEAM_NAME>/tech-exercise). From left panel, go tp Settings > Integrations. 


update your `ubiquitous-journey/values-tooling.yaml` to include Nexus with some sensible defaults 
```yaml
  # Nexus
  - name: nexus
    enabled: true
    source: https://redhat-cop.github.io/helm-charts
    chart_name: sonatype-nexus
    source_ref: "1.0.0"
    values:
      service:
        name: nexus
```

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🦘 ADD - nexus repo manager 🦘" 
git push 
```

observe ArgoCD that nexus spins up and connect to Nexus itself to verify
