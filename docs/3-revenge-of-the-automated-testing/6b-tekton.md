### Extend Tekton Pipeline with Stackrox

👷🏼👷🏼👷🏼 `WIP` 👷🏼👷🏼👷🏼

We are going to make use of the `roxctl` CLI to integrate ACS with out Pipelines. 

#### roxctl

Export these environment variables:
```bash
export ROX_API_TOKEN=eyJhbGciOiJSUzI1NiIsIm...
export ROX_ENDPOINT=central-stackrox.<CLUSTER_DOMAIN>
```

Lets grab the `roxctl` CLI:
```bash
curl -k -L -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_ENDPOINT/api/cli/download/roxctl-linux --output ./roxctl  > /dev/null; echo "Getting roxctl"
chmod +x ./roxctl  > /dev/null
```

The following command checks `build-time` violations of your security policies in images.

We can run a `check` on our `pet-battle` image by doing:
```bash
./roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle:latest --json | jq -c '.alerts[].policy | select ( .severity == "HIGH_SEVERITY" or .severity == "CRITICAL_SEVERITY" )'
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

We can also perform image `scans` directly. Try:
```bash
./roxctl image scan --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle:latest --format pretty
```

We can run the `scan` command with a format of `json, csv, and pretty. default "json"`.

We can try this on the `pet-battle-api` image we built using:
```bash
./roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image \
  image-registry.openshift-image-registry.svc:5000/ateam-test/pet-battle-api@sha256:cf2ccbf8d117c2ea98425f9b70b2b937001ccb9b3cdbd4ab10b42ba8a082caf7


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
```

You can check the shell result of this command:
```bash
if [ $? -eq 0 ]; then
 echo "🦸 no issues found 🦸"; 
else
 echo "🦠 checks failed 🦠"; 
fi
```

We can also check other external images:
```bash
./roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image quay.io/petbattle/pet-battle-api:latest
```

The following command checks build-time and deploy-time violations of your security policies in YAML deployment files.

Use this command to validate Kubernetes resources in our helm template
```
cd /projects/pet-battle-api
payload="$( mktemp )"
helm template -s templates/deployment.yaml -s templates/pdb.yaml -s templates/hpa.yaml -s templates/service.yaml . > $payload
roxctl deployment check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 -f $payload
```

#### kube-linter

Need cluster Task:
```bash
oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kube-linter/0.1/kube-linter.yaml
```

`kube-linter` CLI
```bash
wget https://github.com/stackrox/kube-linter/releases/download/0.2.2/kube-linter-linux.tar.gz
```

Can try it out locally on `chart` folder
```bash
cd /project/pet-battle-api
kube-linter lint chart/
```

List of checks
```bash
kube-linter checks list | grep Name
```
```json
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
```

Run with all default checks in pipeline
```yaml
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
```

Run with selected checks
```yaml
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

#### Pipeline Tasks

Add tasks for

- [ ] `scan` image results
- [ ] `check` build time violations
- [ ] `deployment` configuration checks

```yaml
apiVersion: tekton.dev/v1beta1
kind: ClusterTask
metadata:
  name: rox-image-scan
  namespace: pipeline-demo
spec:
  params:
    - name: rox_central_endpoint
      type: string
      description: Secret containing the address:port tuple for StackRox Central (example - rox.stackrox.io:443)
    - name: rox_api_token
      type: string
      description: Secret containing the StackRox API token with CI permissions
    - name: image
      type: string
      description: Full name of image to scan (example -- gcr.io/rox/sample:5.0-rc1)
    - name: output_format
      type: string
      description:  Output format (json | csv | pretty)
      default: json
  steps:
    - name: rox-image-scan
      image: centos:8
      env:
        - name: ROX_API_TOKEN
          valueFrom:
            secretKeyRef:
              name: $(params.rox_api_token)
              key: rox_api_token
        - name: ROX_CENTRAL_ENDPOINT
          valueFrom:
            secretKeyRef:
              name: $(params.rox_central_endpoint)
              key: rox_central_endpoint
      script: |
        #!/usr/bin/env bash
        set +x
        export NO_COLOR="True"
        curl -k -L -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ENDPOINT/api/cli/download/roxctl-linux --output ./roxctl  > /dev/null; echo "Getting roxctl" 
        chmod +x ./roxctl > /dev/null
        ./roxctl image scan --insecure-skip-tls-verify -e $ROX_CENTRAL_ENDPOINT --image $(params.image) --format $(params.output_format) 
```
