## Extend Tekton Pipeline with A/B Deployments

In this exercise, we'll implement an A/B deployment strategy for the Pet Battle API application using OpenShift Routes and Tekton pipelines. This allows us to run two versions of the application simultaneously and gradually shift traffic between them, enabling safe experimentation and gradual rollouts.

### Understanding OpenShift Route Traffic Splitting

OpenShift Routes provide a powerful mechanism for distributing traffic across multiple services. By default, a Route sends all traffic to a single service. However, OpenShift supports traffic splitting through the use of `alternateBackends`, which allows you to distribute requests across multiple services based on configurable weights.

#### Standard Route Configuration

A typical Route configuration sends 100% of traffic to a single service:

```yaml
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
    weight: 100       <-- All traffic goes to `pet-battle-api` service
  ...
```

#### Route with Traffic Splitting

To split traffic between multiple services, we use the `alternateBackends` field. The weights determine the percentage of traffic each service receives:

```yaml
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
    weight: 80        <-- 80% of traffic goes to `pet-battle-api` service
  alternateBackends: <-- This enables traffic splitting
  - kind: Service
    name: pet-battle-api-b
    weight: 20        <-- 20% of traffic goes to `pet-battle-api-b` service
  ...
```

The Pet Battle API Helm chart already includes built-in support for A/B deployments. We simply need to enable and configure it through the `values.yaml` file, and extend the Tekton pipeline to support the deployment workflow.

---

## Implementing A/B Deployment

We'll create two versions of the Pet Battle API application:
- **Version A**: The existing production version (our control)
- **Version B**: The new experimental version (our variant)

We'll start by deploying both versions, then configure traffic splitting to gradually shift users to the new version while monitoring the results.

### Phase 1: Deploy the Experimental Version (B)

**Step 1: Create the Pet Battle API B Deployment**

We'll add a new application definition for the experimental version. This will be identical to the production version initially, but we'll make changes later to distinguish between the two.

Add the following configuration to `/projects/tech-exercise/pet-battle/stage/values.yaml`:

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

> **Note**: Make sure to adjust the `source_ref` (Helm chart version) and `image_version` to match the versions you have available in your Nexus repository.

The existing Pet Battle API deployment will serve as our **Version A** (the control group).

### Phase 2: Configure Traffic Splitting

**Step 2: Enable A/B Deployment on the Main Route**

Now we need to configure the main Pet Battle API deployment to split traffic between versions A and B. We'll add the `a_b_deploy` configuration to enable traffic splitting.

Edit the `pet-battle-api` application definition in `/projects/tech-exercise/pet-battle/stage/values.yaml` and add the following configuration under the `values` section:

```yaml
      a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'B'
        svc_name: ab-pet-battle-api
```

Your complete `pet-battle-api` definition should look similar to this (version numbers may differ):

```yaml
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
      a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'B'
        svc_name: ab-pet-battle-api
```

### Phase 3: Extend the Tekton Pipeline

**Step 3: Add A/B Deployment Task to the Pipeline**

Now we need to extend the Tekton pipeline to include the A/B deployment workflow. Edit `tekton/templates/pipelines/maven-pipeline.yaml` and add the following task where the placeholder indicates. Make sure you update the `runAfter` parameter accordingly:

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
        - verify-deployment # <-------- Update this runAfter properly
```

> **Note**: Ensure that the `runAfter` parameter correctly references the task that should execute before this one in your pipeline.

**Step 4: Deploy the Configuration**

Commit and push the changes. Argo CD will detect the updates and deploy both versions:

```bash
cd /projects/tech-exercise
git add pet-battle/stage/values.yaml tekton/templates/pipelines/maven-pipeline.yaml
git commit -m "🍿 ADD - pet battle APIs A & B environments 🍿"
git push
```

Watch the OpenShift UI as Argo CD creates the new deployments. You should see both `pet-battle-api` and `ab-pet-battle-api` services and deployments.

**Step 5: Verify the Services**

Confirm that both services are properly created:

```bash
oc get svc -l app.kubernetes.io/instance=pet-battle-api -n ${TEAM_NAME}-stage
oc get svc -l app.kubernetes.io/instance=ab-pet-battle-api -n ${TEAM_NAME}-stage
```

Both services should be visible and ready to receive traffic.

### Phase 4: Make Visual Changes to Version B

To make the A/B test more visible and demonstrate the traffic splitting, we'll modify the Pet Battle API to display a version banner.

**Step 6: Update the HTML Banner**

Before verifying the traffic redirection, let's make a simple application change to make this more visual! Make a change in your Pet Battle API application by introducing the version in the HTML file `/projects/pet-battle-api/src/main/resources/META-INF/resources/index.html` (line 118):

```html
<div class="banner lead">
    A/B Deployment - v3.0.1 - Welcome to Pet Battle API !
</div>
```

**Step 7: Update the Application Version**

Bump the version of the application to trigger a new release by editing the `pom.xml` file found in the root of the `pet-battle-api` project and updating the `version` number. The pipeline will update the `chart/Chart.yaml` with these versions for us:

```xml
<artifactId>pet-battle-api</artifactId>
<version>3.0.1</version>
```

You can also run this command to do the replacement automatically:

```bash
cd /projects/pet-battle-api
mvn -ntp versions:set -DnewVersion=3.0.1
```

**Step 8: Commit and Push the Changes**

Commit all these changes:

```bash
cd /projects/pet-battle-api
git add .
git commit -m "🍕 UPDATED - pet-battle-version to 3.0.1 - A/B Deployment 🍕"
git push
```

> **TIP**: You can use the **tkn** command line tool to observe `PipelineRun` logs in real-time:

```bash
tkn -n ${TEAM_NAME}-ci-cd pr logs -Lf
```

🪄 **Observe the Pipeline Running** - At this point, check in with the other half of the group and see if you've managed to integrate the apps! 🪄

### Phase 5: Deploy the New Version

**Step 9: Update the Image Version in Stage**

Now deploy the new version by modifying the `image_version` value in the `tech-exercise/pet-battle/stage/values.yaml` file:

```bash
cd /projects/tech-exercise
yq eval -i '.applications.ab-pet-battle-api.source_ref="3.0.1"' pet-battle/stage/values.yaml
yq eval -i '.applications.ab-pet-battle-api.values.image_version="3.0.1"' pet-battle/stage/values.yaml
git add pet-battle/stage/values.yaml
git commit -m "🏋️‍♂️ service A with new image version 🏋️‍♂️"
git push
```

> **Remember**: If it's not in Git, it's not real! Always commit your configuration changes.

### Phase 6: Observe the A/B Deployment in Action

**Step 10: Test the Initial Traffic Split**

Argo CD triggers the new version deployment while `ab-pet-battle-api` is still running in the previous version.

With the current configuration (80% to A, 20% to B), when you access the application, you have a 20% chance of seeing the version banner. Get the route URL:

```bash
oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
```

Open the URL in your browser and refresh several times. You should occasionally see the version banner, demonstrating that traffic is being split between the two versions.

You can also test this from the command line:

```bash
ROUTE=$(oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}')
for i in `seq 1 10`; do curl https://${ROUTE} -k -s | grep -i welcome; done
```

> **Tip**: The traffic splitting happens at the Route level, so each request has a 20% chance of being routed to Version B. You may need to refresh multiple times or run the curl command several times to see the version banner.

### Phase 7: Adjust Traffic Distribution

Now let's experiment with different traffic distributions to see how easy it is to adjust the split.

**Step 11: Increase Traffic to Version B (50/50 Split)**

Let's increase the traffic to Version B to 50% to get more data faster. Update the weight values in `tech-exercise/pet-battle/stage/values.yaml`:

```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-api.values.a_b_deploy.a_weight='50' pet-battle/stage/values.yaml
yq eval -i .applications.pet-battle-api.values.a_b_deploy.b_weight='50' pet-battle/stage/values.yaml
git add pet-battle/stage/values.yaml
git commit -m "🏋️‍♂️ service B weight increased to 50% 🏋️‍♂️"
git push
```

> **Note**: In OpenShift Routes, weights are relative, not absolute percentages. Setting both to 50 means a 50/50 split (50:50 = 50%:50%).

**Step 12: Test the 50/50 Split**

After Argo CD syncs the changes, test the application again. Open an incognito browser window (to avoid caching) and access the route:

```bash
oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
```

With a 50/50 split, you should see the version banner approximately half the time when refreshing the page or running the curl command.

### Phase 8: Complete the Rollout

**Step 13: Redirect All Traffic to Version A**

After monitoring the results, let's redirect all traffic back to Version A (the original production version). Update the weight values:

```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-api.values.a_b_deploy.a_weight='0' pet-battle/stage/values.yaml
yq eval -i .applications.pet-battle-api.values.a_b_deploy.b_weight='100' pet-battle/stage/values.yaml
git add pet-battle/stage/values.yaml
git commit -m "💯 service B weight increased to 100 💯"
git push
```

**Step 14: Verify the Traffic Redirection**

After Argo CD applies the changes, test the application again:

```bash
oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}'
```

You can also verify from the command line:

```bash
ROUTE=$(oc get route/pet-battle-api -n ${TEAM_NAME}-stage --template='{{.spec.host}}')
for i in `seq 1 10`; do curl https://${ROUTE} -k -s | grep -i welcome; done
```

All requests should now be routed to Version A, confirming that the traffic split has been adjusted as configured.

---

## Summary

In this exercise, you've learned how to:
1. Create multiple versions of an application for A/B testing
2. Configure OpenShift Routes to split traffic between versions
3. Extend Tekton pipelines to support A/B deployment workflows
4. Gradually adjust traffic distribution (20% → 50% → 100%)
5. Make data-driven decisions about application rollouts

This GitOps-based approach ensures that all configuration changes are version-controlled, auditable, and reproducible. The traffic splitting can be adjusted at any time by simply updating the weights in the Git repository, and Argo CD will automatically apply the changes. The Tekton pipeline integration allows you to automate the entire deployment process, making A/B testing a seamless part of your CI/CD workflow.
