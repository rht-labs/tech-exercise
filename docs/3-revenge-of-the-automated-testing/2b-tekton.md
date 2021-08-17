### Extend Tekton Pipeline with Automated Testing

Install **Allure**, a test repository manager. Edit `ubiquitous-journey/value-tooling.yaml` file, add:

```yaml
  # Allure
  - name: allure
    enabled: true
    source: https://github.com/eformat/allure.git
    source_path: "chart"
    source_ref: "main"
```

Add the `allure-post-report.yaml` Task
```yaml
cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/allure-post-report.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: allure-post-report
  labels:
    app.kubernetes.io/version: "0.2"
    rht-labs.com/uj: ubiquitous-journey
spec:
  description: >-
    This task used for uploading test reports to allure
  workspaces:
    - name: output
  params:
    - name: APPLICATION_NAME
      type: string
      default: ""
    - name: IMAGE
      description: the image to use to upload results
      type: string
      default: "quay.io/openshift/origin-cli:4.8"
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
      type: string
    - name: ALLURE_USERNAME
      description: "Allure Username"
      default: "admin"
    - name: ALLURE_PASSWORD
      description: "Allure Password"
      default: "password"
    - name: ALLURE_HOST
      description: "Allure Host"
      default: "http://allure:5050"
  steps:
    - name: save-tests
      image: $(params.IMAGE)
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      script: |
        #!/bin/bash
        curl -sLo send_results.sh https://raw.githubusercontent.com/eformat/allure/main/scripts/send_results.sh && chmod 755 send_results.sh
        ./send_results.sh $(params.APPLICATION_NAME) \
          $(workspaces.output.path)/$(params.WORK_DIRECTORY) \
          $(params.ALLURE_USERNAME) \
          $(params.ALLURE_PASSWORD) \
          $(params.ALLURE_HOST)
EOF
```

Add the `save-test-results` step to our pipeline.

```yaml
    # Save Test Results
    - name: save-test-results
      taskRef:
        name: allure-post-report
      params:
        - name: APPLICATION_NAME
          value: "$(params.APPLICATION_NAME)"
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
      runAfter:
        - code-analysis
      workspaces:
        - name: output
          workspace: shared-workspace
```

Git add, commit, push your changes

```bash
git add .
git commit -m  "🥽 ADD - save-test-results step 🥽" 
git push 
```

Trigger a pipeline build

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🧦 test save-test-results step 🧦"
git push
```

Browse to uploaded test results in Allure:

```bash
https://allure-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/allure-docker-service/projects/pet-battle-api/reports/latest/index.html
```

Can also find these from Allure swagger api.

![images/allure-api.png](images/allure-api.png)

Browse Test results + behaviours.

![images/allure-test-suite.png](images/allure-test-suite.png)

Drill down to test body attachments.

![images/allure-behaviours.png](images/allure-behaviours.png)

### Continuous Testing

- https://quarkus.io/guides/continuous-testing

<pre>
The following commands are available:
[r] - Re-run all tests
[f] - Re-run failed tests
[b] - Toggle 'broken only' mode, where only failing tests are run (disabled)
[v] - Print failures from the last test run
[p] - Pause tests
[o] - Toggle test output (disabled)
[i] - Toggle instrumentation based reload (disabled)
[l] - Toggle live reload (enabled)
[s] - Force restart
[h] - Display this help
[q] - Quit
</pre>

Run tests.

```bash
mvn quarkus:test
```

Add a new failing test.

```java
    @Test
    @Story("Test me")
    void testMe() {
        Assert.assertFalse(false);
    }
```

![images/quarkus-continuous-test-fail.png](images/quarkus-continuous-test-fail.png)

Switch to **broken only mode** by pressing `b`

![images/quarkus-continuous-test-broken-only.png](images/quarkus-continuous-test-broken-only.png)

Make the test pass.

```java
    @Test
    @Story("Test me")
    void testMe() {
        Assert.assertFalse(true);
    }
```

![images/quarkus-continuous-test-fix.png](images/quarkus-continuous-test-fix.png)

```bash
git add .
git commit -m  "⛑️ ADD - new test ⛑️" 
git push 
```

Allure new test added, test trend shown.

![images/allure-new-test-add.png](images/allure-new-test-add.png)

`TODO`

- [ ] Document the steps
- [ ] Allure Task should this be in repo already?
- [ ] Allure Annotations, Add a new test, Historical test results
