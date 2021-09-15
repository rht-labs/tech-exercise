### Extend Tekton Pipeline with Sonar Scanning

> In this exercise, we're going to edit the tekton `Pipeline` to run code-analysis using sonar of the API and add an additional `Task` to analyse the results

1. Add `code-analysis` step to our `Pipeline`. Edit `tech-exercise/tekton/templates/pipelines/maven-pipeline.yaml` file, add this step before the `maven` build step. We don't need to create a new task here, we can just supply some new parameters to the existing `maven` task giving us great reusability of Tekton components.

```yaml
    # Code Analysis
    - name: code-analysis
      taskRef:
        name: maven
      params:
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
        - name: GOALS
          value:
            - test
            # - org.owasp:dependency-check-maven:check
            - sonar:sonar
        - name: MAVEN_BUILD_OPTS
          value:
            - '-Dsonar.host.url=http://sonarqube-sonarqube:9000'
            - '-Dsonar.userHome=/tmp/sonar'
            - '-Dsonar.login=admin'
            - '-Dsonar.password=admin123'
      runAfter:
        - fetch-app-repository
      workspaces:
        - name: maven-settings
          workspace: maven-settings
        - name: maven-m2
          workspace: maven-m2
        - name: output
          workspace: shared-workspace
        # - name: sonarqube-auth
        #   secret:
        #     secretName: sonarqube-auth
```

2. Tekton Tasks are just piece of yaml. So it's easy for us to add more tasks. The Tekton Hub is a great place to go find some reusable components for doing specific activities. In our case, we're going to grab the `sonarqube-quality-gate-check.yaml` task and add it to our cluster. If you open `tekton/templates/tasks/sonarqube-quality-gate-check.yaml` file afterwards, you'll see the task is a simple one that executes one shell script in an image. 

```bash
curl -sLo /projects/tech-exercise/tekton/templates/tasks/sonarqube-quality-gate-check.yaml \
    https://raw.githubusercontent.com/petbattle/ubiquitous-journey/main/tekton/tasks/sonarqube-quality-gate-check.yaml
```

3. Let's add this task to our pipleine. Edit `tech-exercise/tekton/templates/pipelines/maven-pipeline.yaml` file and add the `code-analysis-check` step to our pipeline as shown below.

```yaml
    # Code Analysis Check
    - name: analysis-check
      retries: 1
      taskRef:
        name: sonarqube-quality-gate-check
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
      - name: WORK_DIRECTORY
        value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
      runAfter:
      - code-analysis
```

4. In Tekton, we can control flow by using `runAfter` to organize the structure of the pipeline. Adjust the `maven` build step's `runAfter` to be `analysis-check` so the static analysis steps happen before we even compile the app!

<code class="language-yaml">
    - name: maven
      taskRef:
        name: maven
      params:
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
        - name: GOALS
          value:
            - "package"
        - name: MAVEN_BUILD_OPTS
          value:
            - "-Dquarkus.package.type=fast-jar"
            - "-DskipTests"
      workspaces:
        - name: maven-settings
          workspace: maven-settings
        - name: maven-m2
          workspace: maven-m2
        - name: output
          workspace: shared-workspace
      <strong>runAfter:
        - analysis-check</strong>
</code></pre>

5. With all these changes in place - Git add, commit, push your changes so our pipeline definition is updated on the cluster:

```bash
cd /projects/tech-exercise
git add .
git commit -m  "🥽 ADD - code-analysis & check steps 🥽" 
git push 
```

6. Now let's trigger a pipeline build - we can push an empty commit to the repo to trigger the pipeline:

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🧦 TEST - running code analysis steps 🧦"
git push
```

?> **TIP** - If we didn't want to add a commit to the repo, we could always go to GitLab and trigger the WebHook directly from there which would also kick the pipeline but leave no trace in the git history 🧙‍♀️✨🧙‍♀️.

![images/sonar-pb-api-code-quality](images/sonar-pb-api-code-quality.png)

7. When the pipeline has complete - we can inspect the results in SonarQube UI. Browse to Sonarqube URL

```bash
echo https://$(oc get route sonarqube --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)
```
![images/sonar-pb-api.png](images/sonar-pb-api.png)
