## 🔥🦄 Ubiquitous Journey
blah blah what it is, why we use it
Extensible, traceable, auditable ...

```bash
# create a Group in GitLab for your team

# create a repo in GitLab in that group

# setup the pre-cloned git repo in CRW
git remote rename origin old-origin
git remote add origin https://gitlab-ce.do500-gitlab.${CLUSTER_DOMAIN}/${TEAM_NAME}/tech-excercise.git
git push -u origin --all
git push -u origin --tags
```

Take a walk in values-tooling.yaml file...
* Boostrap projects 
* Jenkins
* Tekton

### Take a walk in values.yaml file... [pb enabled false]

Update your `values.yaml`
- update  the `source` URL to be your `GITHUB_URL`
- change your `<TEAM_NAME>` in the bootstrap section
```bash
source: source: "https://gitlab-ce.do500-gitlab.<CLUSTER_DOMAIN>/<TEAM_NAME>/tech-exercise.git"
team: <TEAM_NAME>
```

Update your `ubiquitous-journey/values-tooling.yaml`
- change your `<TEAM_NAME>` in the bootstrap section
```yaml
        - name: jenkins
          kind: ServiceAccount
          role: admin
          namespace: <TEAM_NAME>-ci-cd
      namespaces:
        - name: <TEAM_NAME>-ci-cd
          bindings: *binds
        - name: <TEAM_NAME>-dev
          bindings: *binds
        - name: <TEAM_NAME>-test
          bindings: *binds
        - name: <TEAM_NAME>-stage
          bindings: *binds
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

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🦆 ADD - correct project names 🦆" 
git push 
```

Install all the tooling in UJ (only bootstrap, and Jenkins at this stage..)
```bash
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .
```
show namespaces & Jenkins spinning up via ArgoCD 

Show resources in the cluster
```bash
oc get projects | grep ${TEAM_NAME}
```
```bash
oc get pods -n ${TEAM_NAME}-ci-cd
```

TODO - fix bootstrap for dummy-sa (sort of did at the time being)