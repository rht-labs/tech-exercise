## Extend Tekton Pipeline with System Test


1. Add a task to the tekton pipeline for running the system testing:

    ```bash
    cd /projects/tech-exercise
    cat <<'EOF' > tekton/templates/tasks/system-testing.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Task
    metadata:
      name: system-testing
    spec:
      workspaces:
        - name: output
      params:
        - name: WORK_DIRECTORY
          description: Directory to start build in (handle multiple branches)
          type: string
        - name: APP_URL
          description: The application under test url
          type: string
        - name: ZAP_URL
          description: The zalenium service url
          type: string
      steps:
        - name: system-testing
          image: registry.redhat.io/rhel9/nodejs-20:9.5
          workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
          script: |
            #!/usr/bin/env bash
            export ZALENIUM_SERVICE_HOST=$(params.ZAP_URL)
            export E2E_TEST_ROUTE=$(params.APP_URL)
            npm ci
            npm run e2e:ci
    EOF
    ```

3. Let's add this task into pipeline. Edit `tekton/templates/pipelines/maven-pipeline.yaml` and copy below yaml where the placeholder is. Make sure you update `runAfter` accordingly.

    ```yaml
        # System Testing
        - name: fetch-system-test-repo
          runAfter:
            - verify-deployment  # Important to modify this runAfter properly
          taskRef:
            resolver: cluster
            params:
            - name: kind
              value: task
            - name: name
              value: git-clone
            - name: namespace
              value: openshift-pipelines 
          workspaces:
            - name: output
              workspace: shared-workspace
          params:
            - name: URL
              value: "https://{{ .Values.git_server }}/{{ .Values.team }}/system-tests.git"
            - name: REVISION
              value: "main"
            - name: SUBDIRECTORY
              value: "system-testing"
            - name: DELETE_EXISTING
              value: "true"
            - name: SSL_VERIFY
              value: "false"

        - name: system-testing
          runAfter:
            - fetch-system-test-repo
          taskRef:
            name: system-testing
          workspaces:
            - name: output
              workspace: shared-workspace
          params:
            - name: ZAP_URL
              value: "zalenium-{{ .Values.team }}-ci-cd.{{ .Values.cluster_domain }}"
            - name: APP_URL
              value: "pet-battle-{{ .Values.team }}-test.{{ .Values.cluster_domain }}"
            - name: WORK_DIRECTORY
              value: "system-testing"
    ```

4. Remember -  if it's not in git, it's not real.

    ```bash
    cd /projects/tech-exercise/tekton
    git add .
    git commit -m  "🥒 ADD - System testing task 🥒"
    git push
    ```

5. Trigger a pipeline build.

    ```bash
    cd /projects/pet-battle-api
    git commit --allow-empty -m "🩴 test image-scan step 🩴"
    git push

    🪄 Observe the **pet-battle-api** pipeline running with the **system-testing** task.


6. Zalenium also has some cool features, you can show the tests execution both live and via the recording. Just go to the url of your running Zalenium http://zalenium-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/dashboard to see a recording of the test cases executing. Note - for the live execution of tests it's http://zalenium-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/grid/admin/live?refresh=5

![zalenium-dashboard](images/zalenium-dashboard.png)