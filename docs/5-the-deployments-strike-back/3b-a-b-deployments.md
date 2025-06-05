## Extend Tekton Pipeline with A/B Deployments

As you see in the diagram, OpenShift can distribute the traffic that coming to Route. But how does it do it? Let's explore `route` definition. This is a classic Route definition:

  <div class="highlight" style="background: #f7f7f7">
  <pre><code class="language-yaml">
  apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: pet-battle-api
  spec:
    port:
      targetPort: 8080-tcp
    to:
      kind: Service
      name: pet-battle
      weight: 100       <-- All of the traffic goes to `pet-battle` service
    ...
  </code></pre></div>

  In order to split the traffic, we introduce something called `alternateBackends`.

  <div class="highlight" style="background: #f7f7f7">
  <pre><code class="language-yaml">
  apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: pet-battle-api
  spec:
    port:
      targetPort: 8080-tcp
    to:
      kind: Service
      name: pet-battle-api
      weight: 80
    alternateBackends: <-- This helps us to divide the traffic
    - kind: Service
      name: pet-battle-api-b
      weight: 20       <-- based on the percentage we give
  </code></pre></div>

### A/B Deployment

1. Let's deploy our experiment we want to compare -  let's call this `B`. Adjust the `source_ref` helm chart version and `image_version` to match what you have built.

    ```bash
    cat << EOF >> /projects/tech-exercise/pet-battle/stage/values.yaml
      # Pet Battle API - A/B Experiment
      ab-pet-battle-api:
        name: ab-pet-battle-api
        enabled: true
        source: http://nexus:8081/repository/helm-charts
        chart_name: pet-battle-api
        source_ref: 1.5.0  # <----------- IMPORTANT: Define the current Pet Battle API version
        values:
          image_name: pet-battle-api
          image_version: latest
          image_repository: image-registry.openshift-image-registry.svc:5000
          image_namespace: <TEAM_NAME>-stage
          hpa:
            enabled: false
          route: false
    EOF
    ```

    We will use our existing Pet Battle deployment as `A`.

2. Extend the configuration for the existing Pet Battle deployment (`A`) by adding the `a_b_deploy` properties to the `values` section. Copy the below lines under `pet-battle` application definition in `/projects/tech-exercise/pet-battle/stage/values.yaml` file.

    ```yaml
          a_b_deploy:
            a_weight: 80
            b_weight: 20 # 20% of the traffic will be directed to 'A'
            svc_name: ab-pet-battle-api
    ```

    The `ab-pet-battle-api` definition in `stage/values.yaml` should look something like this (the version numbers may be different):

    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
      pet-battle-api:
        name: pet-battle-api
        enabled: true
        source: http://nexus:8081/repository/helm-charts
        chart_name: pet-battle-api
        source_ref: 1.5.0  # <----------- IMPORTANT: Define the current Pet Battle API version
        values:
          image_name: pet-battle-api
          image_version: latest
          image_namespace: <TEAM_NAME>-stage
          image_repository: image-registry.openshift-image-registry.svc:5000
          hpa:
            enabled: false 
    <strong>      a_b_deploy:
            a_weight: 80
            b_weight: 20 # 20% of the traffic will be directed to 'B'
            svc_name: ab-pet-battle-api</strong>
    </code></pre></div>


3. Let's add this task into pipeline. Edit `tekton/templates/pipelines/maven-pipeline.yaml` and copy below yaml where the placeholder is. Make sure you update `runAfter` accordingly.

    ```yaml
      # A/B Deployment
      - name: promote-image-stage
        taskRef:
          name: promote-image-stage
        workspaces:
          - name: output
            workspace: shared-workspace
        params:
          - name: APPLICATION_NAME
            value: "$(params.APPLICATION_NAME)"
          - name: TEAM_NAME
            value: "$(params.TEAM_NAME)"
          - name: VERSION
            value: "$(tasks.maven.results.VERSION)"
        runAfter: 
          - verify-deployment # <-------- Update this runafter properly

4. Git commit the changes and in OpenShift UI, you'll see two new deployments are coming alive.

    ```bash
    cd /projects/tech-exercise
    git add pet-battle/stage/values.yaml
    git commit -m  "🍿 ADD - pet battle APIs A & B environments 🍿"
    git push
    ```

5. Verify if you have the both service definition.

    ```bash
    oc get svc -l app.kubernetes.io/instance=pet-battle-api -n ${TEAM_NAME}-stage
    oc get svc -l app.kubernetes.io/instance=ab-pet-battle-api -n ${TEAM_NAME}-stage
    ```

6. Before verify the traffic redirection, let's make a simple application change to make this more visual! Make a change un your Pet Battle API application introducing the version in the HTLM file `/projects/pet-battle-api/src/main/resources/META-INF/resources/index.html` (line 118).

   ```bash
    <div class="banner lead">
        A/B Deployment - v3.0.1 - Welcome to Pet Battle API !
    </div>
  ```

7. Bump the version of the application to trigger a new release by editing pet-battle-api `pom.xml` found in the root of the `pet-battle-api` project and update the `version` number. The pipeline will update the `chart/Chart.yaml` with these versions for us.

    ```xml
        <artifactId>pet-battle-api</artifactId>
        <version>3.0.1</version>
    ```

    You can also run this bit of code to do the replacement if you are feeling uber lazy!

    ```bash
    cd /projects/pet-battle-api
    mvn -ntp versions:set -DnewVersion=3.0.1
    ```
8. Commit all these changes:

    ```bash
    cd /projects/pet-battle-api
    git add .
    git commit -m  "🍕 UPDATED - pet-battle-version to 3.0.1 - A/B Deployment 🍕"
    git push
    ```
?> **TIP** You can use the **tkn** command line to observe `PipelineRun` logs as well:

```bash
tkn -n ${TEAM_NAME}-ci-cd pr logs -Lf
```

🪄OBSERVE PIPELINE RUNNING :D - At this point, check in with the other half of the group and see if you’ve managed to integrate the apps🪄

9. Now deploy the new version "manually" in stage modifying `image_version` value in `tech-exercise/pet-battle/stage/values.yaml` file.
And as always, push it to the Git repository - <strong>Because if it's not in Git, it's not real!</strong>

    ```bash
    cd /projects/tech-exercise
    yq eval -i '.applications.ab-pet-battle-api.source_ref="3.0.1"' pet-battle/stage/values.yaml
    yq eval -i '.applications.ab-pet-battle-api.values.image_version="3.0.1"' pet-battle/stage/values.yaml
    git add pet-battle/stage/values.yaml
    git commit -m  "🏋️‍♂️ service A with new image version 🏋️‍♂️"
    git push
    ```

10. ArgoCD triggers the new version deployment while `ab-pet-battle-api` is still running in the previous version.

    If you open up `pet-battle-api` in your browser, 20 percent of the traffic is going to `b`. You have a little chance to see the version in the banner.

    ```bash
    oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
    ```

    You can use the command line...

    ```bash
    ROUTE=$(oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}')
    for i in `seq 1 10`; do curl https://${ROUTE} -k -s | grep -i welcome; done
    ```

11. Now let's redirect 50% of the traffic to `B`, that means that only 50% of the traffic will go to `A`. So you need to update `weight` value in `tech-exercise/pet-battle/stage/values.yaml` file.
And as always, push it to the Git repository - <strong>Because if it's not in Git, it's not real!</strong>

    ```bash
    cd /projects/tech-exercise
    yq eval -i .applications.pet-battle-api.values.a_b_deploy.a_weight='50' pet-battle/stage/values.yaml
    yq eval -i .applications.pet-battle-api.values.a_b_deploy.b_weight='50' pet-battle/stage/values.yaml
    git add pet-battle/stage/values.yaml
    git commit -m  "🏋️‍♂️ service B weight increased to 50% 🏋️‍♂️"
    git push
    ```

12. Open an incognito browser and connect to the same URL. You'll have 50% chance to get the version included banner.

    ```bash
    oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
    ```

13. Apparently people like the version included banner on PetBattle API UI! Let's redirect all traffic to service `A`. Yes, for that we need to make weight 0 for service `B`. If you refresh the page, you should only see the green banner.

    ```bash
    cd /projects/tech-exercise
    yq eval -i .applications.pet-battle-api.values.a_b_deploy.a_weight='100' pet-battle/stage/values.yaml
    yq eval -i .applications.pet-battle-api.values.a_b_deploy.b_weight='0' pet-battle/stage/values.yaml
    git add pet-battle/stage/values.yaml
    git commit -m  "💯 service B weight increased to 100 💯"
    git push
    ```

14. Open an incognito browser and connect to the same URL. You'll have 100% chance to get the version included banner.

    ```bash
    oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
    ```

    You can use the command line...

    ```bash
    ROUTE=$(oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}')
    for i in `seq 1 10`; do curl https://${ROUTE} -k -s | grep -i welcome; done
    ```
