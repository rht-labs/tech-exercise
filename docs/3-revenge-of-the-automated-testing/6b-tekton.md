### Extend Tekton Pipeline with OWASP Zap Security Scanning

> What is [owasp zed attack proxy]([https://www.zaproxy.org/)

Note: You will need to have *Allure* deployed from the testing step to run this task.

1. Add a task into our codebase to zap scan our deployed app in test

```bash
cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/zap-proxy.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: zap-proxy
spec:
  workspaces:
    - name: output
  params:
    - name: APPLICATION_NAME
      type: string
      default: "zap-scan"
    - name: APP_URL
      description: The application under test url
    - name: ALLURE_HOST
      type: string
      description: "Allure Host"
      default: "http://allure:5050"
    - name: ALLURE_SECRET
      type: string
      description: Secret containing Allure credentials
      default: allure-auth
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
  steps:
    - name: zap-proxy
      image: quay.io/eformat/zap2docker-stable:latest
      env:
        - name: PIPELINERUN_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['tekton.dev/pipelineRun']
        - name: ALLURE_USERNAME
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: username
        - name: ALLURE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: password
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      script: |
        #!/usr/bin/env bash
        set -x
        echo "Make the wrk directory available to save the reports"
        cd /zap
        mkdir -p /zap/wrk /zap/target
        ln -s /zap/wrk target/allure-results
        echo "🪰🪰🪰 Starting the pen test..."
        /zap/zap-baseline.py -t $(params.APP_URL) -r $PIPELINERUN_NAME.html
        ls -lart target/allure-results/
        echo "🛸🛸🛸 Saving results..."
        curl -sLo send_results.sh https://raw.githubusercontent.com/eformat/allure/main/scripts/send_results.sh && chmod 755 send_results.sh
        ./send_results.sh $(params.APPLICATION_NAME) \
        /zap \
        ${ALLURE_USERNAME} \
        ${ALLURE_PASSWORD} \
        $(params.ALLURE_HOST)
EOF
```

2. Lets try this in our pipeline. Edit `maven-pipeline.yaml` and add a step definition for `pentesting-test`. Remember to adjust the `runAfter` to match the current state of your pipeline:

```yaml
    # PEN TESTING
    - name: pentesting-test
      taskRef:
        name: zap-proxy
      runAfter:
        - verify-deployment
      params:
        - name: APP_URL
          value: "https://pet-battle-{{ .Values.team }}-test.{{ .Values.cluster_domain }}"
      workspaces:
        - name: output
          workspace: shared-workspace
```

3. Check our changes into git.

```bash
cd /projects/tech-exercise
# git add, commit, push your changes..
git add .
git commit -m  "🪰 ADD - zap scan pentest 🪰" 
git push
```

4. Trigger a pipeline build.

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🩴 test zap-scan step 🩴"
git push
```

5. Check report in *Allure*

```bash
echo https://allure-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/allure-docker-service/projects/zap-scan/reports/latest/index.html
```



Can also find these from Allure swagger api.

![images/allure-api.png](images/allure-api.png)

Browse Test results + behaviours.

![images/allure-test-suite.png](images/allure-test-suite.png)

Drill down to test body attachments.

![images/allure-behaviours.png](images/allure-behaviours.png)
