### Extend Tekton Pipeline with Kube Linting Task

Let's enable the **kube-linter** task in our pipeline.

1. Add the cluster Task:

```bash
curl -sLo /projects/tech-exercise/tekton/templates/tasks/kube-linter.yaml https://raw.githubusercontent.com/tektoncd/catalog/main/task/kube-linter/0.1/kube-linter.yaml
```

```bash
cd /projects/tech-exercise
git add .
git commit -m  "☎️ ADD - kube-linter task ☎️" 
git push
```

2. Let's try StackRox **kube-linter** out locally on the **chart** folder

```bash
cd /project/pet-battle-api
kube-linter lint chart/
```

3. List of checks the linter performs

```bash
kube-linter checks list | grep Name
```

<pre>
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
</pre>


4. We could run the **kube-linter** task with all default checks in our pipeline. This would fail the build.

<pre>
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
</pre>

5. Let's run with a restricted set of checks. Add the following step in our `maven-pipeline.yaml`. Be sure to adjust the `maven` Task as well so it runs **after** the `kube-linter` Task.

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

![images/acs-kube-linter-task.png](images/acs-kube-linter-task.png)

### Breaking the Build

Let's run through a scenario where we break/fix the build with **kube-linter**.

1. Edit `maven-pipeline.yaml` and Add the following value **required-label-owner** to the includelist on the **kube-linter** task:

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

5. Let's fix our deployment by adding an **owner** label using helm. Edit `pet-battle-api/chart/values.yaml` file and add a value for **owner**:

```yaml
owner: <TEAM_NAME>
```

6. Now edit `pet-battle-api/chart/_helpers.tpl` and add this in two places - where we **define "pet-battle-api.labels"** and where we **define "mongodb.labels"**

```json
app.kubernetes.io/managed-by: {{ .Release.Service }}
owner: {{ .Values.team }}
```

7. We can check the **kube-linter** command again and check these changes in:

```bash
cd /project/pet-battle-api
git add .
git commit -m  "🐊 ADD - kube-linter owner labels 🐊" 
git push
```

🪄 Obeserve the **pet-battle-api** pipeline running successfully again.
