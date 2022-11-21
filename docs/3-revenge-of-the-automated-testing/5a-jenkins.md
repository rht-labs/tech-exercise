# Extend Jenkins Pipeline with Kube Linting Step

Remember in our pipeline, there is a stage called `"🏗️ Deploy - Helm Package"`. This stage runs `helm lint` and then package the helm chart to store in Nexus. But `helm lint` only checks the chart for possible issues like if there is a wrong intendention etc but we want to extend this stage with `kube-linter` to also check for security misconfigurations and Kubernetes best practices.

1. Add the following code snippet into the placeholder in Jenkinsfile under `/projects/pet-battle/`. It is under `stage("🏗️ Deploy - Helm Package")` stage.

    ```groovy
			// Kube-linter step
			echo '### Kube Lint ###'
			sh '''
			  export default_option="do-not-auto-add-defaults"
			  export includelist="no-extensions-v1beta,no-readiness-probe,no-liveness-probe,dangling-service,mismatching-selector,writable-host-mount"
			  kube-linter lint chart/  --"${default_option}" --include "${includelist}" 
			'''
    ```
    _We use a restricted set of checks but as you see in the beginning with `kube-linter checks list` command, there are more checks you can include._

2. Check our changes into git.
    ```bash
    cd /projects/pet-battle
    # git add, commit, push your changes..
    git add Jenkinsfile
    git commit -m  "🐠 ADD - kube-linter step 🐠"
    git push
    ```
   This push will also trigger the pipeline. Watch the pipeline and observe it fails 🤯🤯

    _You should see something like this:_
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
        chart/pet-battle/templates/deploymentconfig.yaml: (object: <no namespace>/test-release-pet-battle apps.openshift.io/v1, 
        Kind=DeploymentConfig) container "pet-battle" does not specify a liveness probe 
        (check: no-liveness-probe, remediation: Specify a liveness probe in your container. 
        Refer to https://kubernetes.io/docs/tasks/configure-pod-container/
        configure-liveness-readiness-startup-probes/ for details.)

        Error: found 1 lint errors
    </code></pre></div>

    Readiness and Liveness probes are the foundational best practices for tracking application health status. For more info, please refer [here](https://docs.openshift.com/container-platform/4.9/applications/application-health.html).

3. Let's fix this then! Open up `projects/pet-battle/chart/templates/deploymentconfig.yaml` file. In around line 46, you'll see a `readinessProbe` definition. We will add our `livelinessProbe` definition right after that block (line 52). Please mind that it should be aligned with `readinessProbe`.

    ```yaml
            livenessProbe:
              httpGet:
                  path: /
                  port: 8080
              timeoutSeconds: 1
              periodSeconds: 10
              successThreshold: 1
              failureThreshold: 3
    ```

    You should have a YAML file should look like this:
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
    ...
            readinessProbe:
              httpGet:
                  path: /
                  port: 8080
              initialDelaySeconds: 10
              timeoutSeconds: 1
            livenessProbe:
              httpGet:
                  path: /
                  port: 8080
              timeoutSeconds: 1
              periodSeconds: 10
              successThreshold: 1
              failureThreshold: 3
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
    ...
    </code></pre></div>

    Since we made a change in chart, we need to bump the chart version in `Chart.yaml`.
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
	apiVersion: v2
	name: pet-battle
	description: Pet Battle Frontend
	type: application
	version: 1.0.6 <- bump this
	appVersion: 0.0.1
    </code></pre></div>

    Before pushing the changes, let's verify that if this change helps us:

    ```bash
    cd /projects/pet-battle
    kube-linter lint chart --do-not-auto-add-defaults --include no-extensions-v1beta,no-readiness-probe,no-liveness-probe,dangling-service,mismatching-selector,writable-host-mount
    ```

    You should see such output 💪💪
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
    KubeLinter 0.2.6

    No lint errors found!
    </code></pre></div>

4. Again, push the changes into the repository:

	```bash
	cd /projects/pet-battle
	git add .
	git commit -m  "🗻 ADD - Liveliness probe 🗻"
	git push
	```

    This will again trigger the pipeline, but this time you should see a successful output for this stage 🔥🔥🔥
