### Extend Tekton Pipeline with Kube Linting Task

Let's enable the **kube-linter** task in our pipeline.

1. Kube lint has a tekton task on tekton hub so let's grab it and add the `Task` to our cluster. Feel free to explore what the `Task` will be doing 

```bash
curl -sLo /projects/tech-exercise/tekton/templates/tasks/kube-linter.yaml \
  https://raw.githubusercontent.com/tektoncd/catalog/main/task/kube-linter/0.1/kube-linter.yaml
```

```bash
# commit this so ArgoCD will sync it 
cd /projects/tech-exercise
git add .
git commit -m  "☎️ ADD - kube-linter task ☎️" 
git push
```

2. While this is being sync'd to the cluster - let's try StackRox **kube-linter** out locally on the **chart** folder. (As you can see we've got a list of things we need to fix 👀)

```bash
cd /projects/pet-battle-api
kube-linter lint chart/
```

3. Kube Lint has a load of built in best practices to check for when performing a lint. We can list them

```bash
kube-linter checks list | grep Name:
```

<div class="highlight" style="background: #f7f7f7">
<pre><code class="language-yaml">
Name: cluster-admin-role-binding
Name: dangling-service
Name: default-service-account
Name: deprecated-service-account-field
Name: docker-sock
Name: drop-net-raw-capability
Name: env-var-secret
Name: exposed-services
Name: host-ipc
Name: host-network
Name: host-pid
Name: mismatching-selector
Name: no-anti-affinity
Name: no-extensions-v1beta
Name: no-liveness-probe
Name: no-read-only-root-fs
Name: no-readiness-probe
Name: non-existent-service-account
Name: privilege-escalation-container
Name: privileged-container
Name: privileged-ports
Name: required-annotation-email
Name: required-label-owner
Name: run-as-non-root
Name: sensitive-host-mounts
Name: ssh-port
Name: unsafe-proc-mount
Name: unsafe-sysctls
Name: unset-cpu-requirements
Name: unset-memory-requirements
Name: writable-host-mount
</code></pre></div>


4. We could run the **kube-linter** task with all default checks in our pipeline but this would fail the build...

<div class="highlight" style="background: #f7f7f7">
<pre><code class="language-yaml">
    - name: kube-linter
      runAfter:
      - fetch-app-repository
      taskRef:
        name: kube-linter
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: manifest
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)/chart"
</code></pre></div>

5. So let's do the _naughty thing_ and run with a restricted set of checks. Add the following step in our `maven-pipeline.yaml` (stored in `/projects/tech-exercise/tekton/templates/pipelines/maven-pipeline.yaml`). Be sure to update the `maven` Task in the pipeline as well so its `runAfter` is the `kube-linter` Task.

```yaml
    # Kube-linter
    - name: kube-linter
      runAfter:
      - fetch-app-repository
      taskRef:
        name: kube-linter
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: manifest
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)/chart"
        - name: default_option
          value: do-not-auto-add-defaults
        - name: includelist
          value: "no-extensions-v1beta,no-readiness-probe,no-liveness-probe,dangling-service,mismatching-selector,writable-host-mount"

```

7. Check our changes into git.

```bash
cd /projects/tech-exercise
# git add, commit, push your changes..
git add .
git commit -m  "🐡 ADD - kube-linter checks 🐡" 
git push
```

8. Trigger a pipeline build.

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🐡 test kube-linter step 🐡"
git push
```

🪄 Watch the pipeline run with the **kube-linter** task.

![acs-kube-linter-task](./images/acs-kube-linter-task.png)

### Breaking the Build

Let's run through a scenario where we break/fix the build with **kube-linter**.

1. Edit `maven-pipeline.yaml` again and Add the following value **required-label-owner** to the includelist on the **kube-linter** task:

```yaml
        - name: includelist
          value: "no-extensions-v1beta,no-readiness-probe,no-liveness-probe,dangling-service,mismatching-selector,writable-host-mount,required-label-owner"
```

2. Check in these changes and trigger a pipeline run.

```bash
cd /projects/tech-exercise
# git add, commit, push your changes..
git add .
git commit -m  "🐡 ADD - kube-linter required-label-owner check 🐡" 
git push
```

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🩴 test required-label-owner check 🩴"
git push
```

3. Wait for the pipeline to sync and trigger a **pet-battle-api** build. This should now fail.

![images/acs-lint-fail.png](images/acs-lint-fail.png)

4. We can take a look at the error and replicate it on the command line:

```bash
cd /projects/pet-battle-api
kube-linter lint chart --do-not-auto-add-defaults --include no-extensions-v1beta,no-readiness-probe,no-liveness-probe,dangling-service,mismatching-selector,writable-host-mount,required-label-owner
```

![images/acs-owner-label-fail.png](images/acs-owner-label-fail.png)

5. The linter is complaining we're missing a label on our resources - let's fix our deployment by adding an **owner** label using helm. Edit `pet-battle-api/chart/values.yaml` file and add a value for **owner**:

```yaml
owner: <TEAM_NAME>
```

6. In helm land, the `_helpers.tpl` file allows us to define varibales and chunks of yaml that can be reused across all resources in a chart easily. Let's update our label definitions in there to fix the kube-lint issue. Edit `pet-battle-api/chart/_helpers.tpl` and add the `owner` label like this in two places - where we **define "pet-battle-api.labels"** and where we **define "mongodb.labels"** append it below `app.kubernetes.io/managed-by: {{ .Release.Service }}` so it looks like this:

```go
app.kubernetes.io/managed-by: {{ .Release.Service }}
owner: {{ .Values.owner }}
```

7. Since we changed the chart we should update it's version while we're at it. Bump the version in `chart/chart.yaml`

```yaml
version: 1.2.0
```

8. We can check the **kube-linter** command again and check these changes in:

```bash
cd /project/pet-battle-api
git add .
git commit -m  "🐊 ADD - kube-linter owner labels 🐊" 
git push
```

🪄 Obeserve the **pet-battle-api** pipeline running successfully again.
