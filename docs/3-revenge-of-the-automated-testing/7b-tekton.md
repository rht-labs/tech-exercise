### Extend Tekton Pipeline with Stackrox

> We are going to make use of ACS to move security checks into our pipeline. We will look at:
> - **roxctl** - using the ACS/StackRox CLI
> - **kube-linter** - adding the ACS/StackRox kube linter Task to check deployment configurations
> - **scan,check** - container image scanning and policy checking as part of our pipeline using ACS/StackRox

#### roxctl command line

Let's learn how to use the **roxctl** command line.

1. Export these environment variables, your facilitator will give you these from the group exercise.

```bash
export ROX_API_TOKEN=eyJhbGciOiJSUzI1NiIsIm...
export ROX_ENDPOINT=central-stackrox.<CLUSTER_DOMAIN>
```

2. The following command checks **build-time** violations of your security policies in images.

We can run a **check** on our **pet-battle** image by doing:

```bash
roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle:latest --json | jq -c '.alerts[].policy | select ( .severity == "HIGH_SEVERITY" or .severity == "CRITICAL_SEVERITY" )'
```

This returns a Policy error that should look something like this:

```json
Error: Violated a policy with CI enforcement set
{
  "id": "a919ccaf-6b43-4160-ac5d-a405e1440a41",
  "name": "Fixable Severity at least Important",
  "description": "Alert on deployments with fixable vulnerabilities with a Severity Rating at least Important",
  "rationale": "Known vulnerabilities make it easier for adversaries to exploit your application. You can fix these high-severity vulnerabilities by updating to a newer version of the affected component(s).",
  "remediation": "Use your package manager to update to a fixed version in future builds or speak with your security team to mitigate the vulnerabilities.",
  "categories": [
    "Vulnerability Management"
  ],
  "lifecycleStages": [
    "BUILD",
    "DEPLOY"
  ],
  "severity": "HIGH_SEVERITY",
  "enforcementActions": [
    "FAIL_BUILD_ENFORCEMENT"
  ],
  "SORTName": "Fixable Severity at least Important",
  "SORTLifecycleStage": "BUILD,DEPLOY",
  "SORTEnforcement": true,
  "policyVersion": "1.1",
  "policySections": [
    {
      "policyGroups": [
        {
          "fieldName": "Fixed By",
          "values": [
            {
              "value": ".*"
            }
          ]
        },
        {
          "fieldName": "Severity",
          "values": [
            {
              "value": ">= IMPORTANT"
            }
          ]
        }
      ]
    }
  ]
}
```

You can also check the scan results for specific images.

3. We can also perform image **scans** directly. Try:

```bash
roxctl image scan --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle:latest --format pretty
```

We can run the **scan** command with a format of *json, csv, and pretty. default "json"*.

4. We can try this on the **pet-battle-api** image we built using the image reference (this is printed out in the **bake** stage of our pipeline)

```bash
roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image \
  image-registry.openshift-image-registry.svc:5000/ateam-test/pet-battle-api@sha256:cf2ccbf8d117c2ea98425f9b70b2b937001ccb9b3cdbd4ab10b42ba8a082caf7
```

<pre>
✗ Image image-registry.openshift-image-registry.svc:5000/ateam-test/pet-battle-api@sha256:cf2ccbf8d117c2ea98425f9b70b2b937001ccb9b3cdbd4ab10b42ba8a082caf7 failed policy 'Red Hat Package Manager in Image' 
- Description:
    ↳ Alert on deployments with components of the Red Hat/Fedora/CentOS package
      management system.
- Rationale:
    ↳ Package managers make it easier for attackers to use compromised containers,
      since they can easily add software.
- Remediation:
    ↳ Run `rpm -e $(rpm -qa *rpm*) $(rpm -qa *dnf*) $(rpm -qa *libsolv*) $(rpm -qa
      *hawkey*) $(rpm -qa yum*)` in the image build for production containers.
- Violations:
    - Image includes component 'rpm' (version 4.14.3-14.el8_4.x86_64)
</pre>

You can check the shell result of this command:

```bash
if [ $? -eq 0 ]; then
 echo "🦸 no issues found 🦸"; 
else
 echo "🦠 checks failed 🦠"; 
fi
```

5. We can also check other external images. This may take a minute to download and scan the image:

```bash
roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle-api:latest
```

6. The following command checks build-time and deploy-time violations of your security policies in YAML deployment files.

Use this command to validate Kubernetes resources in our helm template
```bash
cd /projects/pet-battle-api/chart
payload="$( mktemp )"
helm template -s templates/deployment.yaml -s templates/pdb.yaml -s templates/service.yaml . > $payload
roxctl deployment check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 -f $payload
```

![images/acs-scan-deployment-cli.png](images/acs-scan-deployment-cli.png)

#### StackRox scan,check Tasks

Lets start by sealing our StackRox credentials.

1. Run this command. This will generate a Kubernetes secret object in `tmp`

```bash
cat << EOF > /tmp/rox-auth.yaml
apiVersion: v1
data:
  password: "$(printf ${ROX_API_TOKEN} | base64 -w0)"
  username: "$(printf ${ROX_ENDPOINT} | base64 -w0)"
kind: Secret
metadata:
  name: rox-auth
EOF
```

2. Use `kubeseal` commandline to seal the secret definition.

```bash
kubeseal < /tmp/rox-auth.yaml > /tmp/sealed-rox-auth.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace do500-shared \
    --controller-name sealed-secrets \
    -o yaml
```

3. We want to grab the results of this sealing activity, in particular the `encryptedData`.

```bash
cat /tmp/sealed-rox-auth.yaml | grep -E 'username|password'
```
<pre>
    username: AgAj3JQj+EP23pnzu...
    password: AgAtnYz8U0AqIIaqYrj...
</pre>

4. In `ubiquitous-journey/values-tooling.yaml` add an entry for `# Sealed Secrets`. Copy the output of `username` and `password` from the previous command and update the values. Make sure you indent the data correctly.

```yaml
  # Sealed Secrets
  - name: sealed-secrets
    enabled: true
    source: https://redhat-cop.github.io/helm-charts
    chart_name: helper-sealed-secrets
    source_ref: "1.0.2"
    values:
      secrets:
        - name: rox-auth
          type: kubernetes.io/basic-auth
          data:
            password: BASE64_ROX_API_TOKEN
            username: BASE64_ROX_ENDPOINT
```

5. Check our changes into git.

```bash
cd /projects/tech-exercise
# git add, commit, push your changes..
git add .
git commit -m  "🔒 ADD - stackrox sealed secret 🔒" 
git push
```

🪄 You should be able to see a **rox-auth** secret in your <TEAM_NAME>-ci-cd namespace.

#### **Scan** Images

1. Add a task into our codebase to scan our built images.

```bash
cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/rox-image-scan.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: rox-image-scan
spec:
  workspaces:
    - name: output
  params:
    - name: ROX_SECRET
      type: string
      description: Secret containing the Stackrox endpoint and token as (username and password)
      default: rox-auth
    - name: IMAGE
      type: string
      description: Full name of image to scan (example -- gcr.io/rox/sample:5.0-rc1)
    - name: OUTPUT_FORMAT
      type: string
      description:  Output format (json | csv | pretty)
      default: json
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
  steps:
    - name: rox-image-scan
      image: registry.access.redhat.com/ubi8/ubi-minimal:8.4
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      env:
        - name: ROX_API_TOKEN
          valueFrom:
            secretKeyRef:
              name: $(params.ROX_SECRET)
              key: password
        - name: ROX_ENDPOINT
          valueFrom:
            secretKeyRef:
              name: $(params.ROX_SECRET)
              key: username
      script: |
        #!/usr/bin/env bash
        set +x
        export NO_COLOR="True"
        curl -k -L -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_ENDPOINT/api/cli/download/roxctl-linux --output roxctl  > /dev/null; echo "Getting roxctl" 
        chmod +x roxctl > /dev/null
        ./roxctl image scan --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image $(params.IMAGE) --format $(params.OUTPUT_FORMAT)
EOF
```

2. Its not real unless its in git

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🐡 ADD - rox-image-scan-task 🐡" 
git push 
```

3. Reinstall our App-of-Apps helm chart with the new definition.
```bash
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .
```

4. Lets try this in our pipeline. Edit `maven-pipeline.yaml` and add a step definition that runs after the **bake** image task. Be sure to adjust the **helm-package** task to `runAfter` the **image-scan** task:

```yaml
    # Image Scan
    - name: image-scan
      runAfter:
      - bake
      taskRef:
        name: rox-image-scan
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: "$(tasks.bake.results.IMAGE)"
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
        - name: OUTPUT_FORMAT
          value: pretty
```

5. Check in these changes.

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🔑 ADD - image-scan step to pipeline 🔑" 
git push 
```

6. Trigger a pipeline build.

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🩴 test image-scan step 🩴"
git push
```

🪄 Obeserve the **pet-battle-api** pipeline running with the **image-scan** task.

#### **Check** Build/Deploy Time Violations

?> **Tip** We could extend the previous check by changing the output format to **json** and installing and using the **jq** command. For example, to check the image scan output and return a results when the **riskScore** and **topCvss** are below a certain value say. These are better handled as *Build Policy* within ACS which we can check next.

1. Lets add another step to our **rox-image-scan** task to check for any build time violations.

```bash
cd /projects/tech-exercise
cat <<'EOF' >> tekton/templates/tasks/rox-image-scan.yaml
    - name: rox-image-check
      image: registry.access.redhat.com/ubi8/ubi-minimal:8.4
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      env:
        - name: ROX_API_TOKEN
          valueFrom:
            secretKeyRef:
              name: $(params.ROX_SECRET)
              key: password
        - name: ROX_ENDPOINT
          valueFrom:
            secretKeyRef:
              name: $(params.ROX_SECRET)
              key: username
      script: |
        #!/usr/bin/env bash
        set +x
        export NO_COLOR="True"
        curl -k -L -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_ENDPOINT/api/cli/download/roxctl-linux --output roxctl  > /dev/null; echo "Getting roxctl" 
        chmod +x roxctl > /dev/null
        ./roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image $(params.IMAGE) --json --json-fail-on-policy-violations=true
        if [ $? -eq 0 ]; then
          echo "🦕 no issues found 🦕"; 
          exit 0;
        else
          echo "🛑 image checks failed 🛑";
          exit 1;
        fi
EOF
```

2. Its not real unless its in git

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🐡 ADD - rox-image-check-task 🐡" 
git push
```

3. Trigger a pipeline run

```bash
cd /projects/pet-battle-api
git commit --allow-empty -m "🩴 test image-check step 🩴"
git push
```

4. Our Pipeline should look like this now with the addition of the **kube-linter** and **image-scan** steps.

![images/acs-tasks-pipe.png](images/acs-tasks-pipe.png)

🪄 Obeserve the **pet-battle-api** pipeline running with the **image-scan** task.

### Breaking the Build

We will run through two break/fix scenarios.
- kube-linter
- build policy violation

#### kube-linter

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

#### Build policy violation

1. Let's try breaking a *Build Policy* within ACS by triggering the *Build* policy we enabled earlier.

2. Edit the `pet-battle-api/Dockerfile.jvm` and add the following line:

```bash
EXPOSE 22
```

3. Check in this change and watch the build that is triggered.

```bash
# git add, commit, push your changes..
cd /projects/pet-battle-api
git add .
git commit -m  "🐉 Expose port 22 🐉" 
git push
```

4. This should now fail on the **image-scan/rox-image-check** task.

![images/acs-image-fail.png](images/acs-image-fail.png)

5. Back in ACS we can also see the failure in the *Violations* view.

![images/acs-violations.png](images/acs-violations.png)

6. Remove the `EXPOSE 22` from the `Dockerfile.jvm` and check it in to make the build pass.

```bash
cd /project/pet-battle-api
git add .
git commit -m  "🐧 FIX - Security violation, remove port 22 exposure 🐧" 
git push
```

🪄 Obeserve the **pet-battle-api** pipeline running successfully again.