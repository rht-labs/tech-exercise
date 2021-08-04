### Tekton Pipeline 
[TODO] Something something what is Tekton (and OpenShift Pipelines)
[TODO] Explain what this Tekton pipeline is going to do
[todo] - add TEkkers to the EF

### structure of this exercise
apply the tekton yaml files [argocd?]
- show tasks sync'd in UI and OpenShift Pipelines view 

Add a task
1 - sync it (git add) 
2 - Fork PB-API to GitLab. Get EventListener URL and add it as webhook to ze Git
3 - update the file
4 - see it works

pulled from other exercise ....
```
- update  the `source` URL to be your `GITHUB_URL`
```yaml
  # Tekton Pipelines
  - name: tekton-pipeline
    enabled: true
    source: "https://gitlab-ce.do500-gitlab.<CLUSTER_DOMAIN>/<TEAM_NAME>/tech-exercise.git"
    source_ref: main
    source_path: tekton
    values:
      team: <TEAM_NAME>
```


🪄 OBSERVE PIPELINE RUNNING :D 

