## Extend Jenkins Pipeline with A/B Deployments

In this exercise, we'll implement an A/B deployment strategy for the Pet Battle application using OpenShift Routes. This allows us to run two versions of the application simultaneously and gradually shift traffic between them, enabling safe experimentation and gradual rollouts.

### Understanding OpenShift Route Traffic Splitting

OpenShift Routes provide a powerful mechanism for distributing traffic across multiple services. By default, a Route sends all traffic to a single service. However, OpenShift supports traffic splitting through the use of `alternateBackends`, which allows you to distribute requests across multiple services based on configurable weights.

#### Standard Route Configuration

A typical Route configuration sends 100% of traffic to a single service:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: pet-battle
spec:
  port:
    targetPort: 8080-tcp
  to:
    kind: Service
    name: pet-battle
    weight: 100       <-- All traffic goes to `pet-battle` service
  ...
```

#### Route with Traffic Splitting

To split traffic between multiple services, we use the `alternateBackends` field. The weights determine the percentage of traffic each service receives:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: pet-battle
spec:
  port:
    targetPort: 8080-tcp
  to:
    kind: Service
    name: pet-battle
    weight: 80        <-- 80% of traffic goes to `pet-battle` service
  alternateBackends: <-- This enables traffic splitting
  - kind: Service
    name: pet-battle-b
    weight: 20        <-- 20% of traffic goes to `pet-battle-b` service
  ...
```

The Pet Battle UI Helm chart already includes built-in support for A/B deployments. We simply need to enable and configure it through the `values.yaml` file. However, before we set up the A/B deployment, we need to deploy an analytics tool to measure the impact of our changes.

---

## Setting Up Analytics with Matomo

A/B deployments are most valuable when you can measure their impact. Simply splitting traffic isn't enough—we need to track user behavior, performance metrics, and feature adoption to make informed decisions about which version performs better.

> **Why Analytics Matter**: The purpose of advanced deployment strategies like A/B testing is to experiment with new features, measure user acceptance, evaluate performance differences, and make data-driven decisions. Without proper analytics, you're flying blind. We'll use **Matomo**, an open-source analytics platform, to get detailed insights into user behavior and application performance.

### Deploying Matomo

We'll deploy Matomo through Argo CD, which will manage the application lifecycle automatically.

**Step 1: Add Matomo to the Argo CD Configuration**

Open the `tech-exercise/ubiquitous-journey/values-tooling.yaml` file and add the following application definition:

```yaml
      # Matomo
      - name: matomo
        enabled: true
        source: https://petbattle.github.io/helm-charts
        chart_name: matomo
        source_ref: "11.0.1"
```

**Step 2: Commit and Push the Changes**

Commit the changes to trigger Argo CD to deploy Matomo:

```bash
cd /projects/tech-exercise
git add .
git commit -m "📈 ADD - matomo app 📈"
git push
```

**Step 3: Monitor the Deployment**

Watch the Matomo pods as they come online:

```bash
oc get pod -n ${TEAM_NAME}-ci-cd -w
```

**Step 4: Access Matomo**

Once the pods are running, retrieve the Matomo URL and access the web interface:

```bash
echo https://$(oc get route/matomo -n ${TEAM_NAME}-ci-cd --template='{{.spec.host}}')
```

Use the following credentials to log in:
- **Username**: `admin`
- **Password**: `My$uper$ecretPassword123#`

**Step 5: Verify Pet Battle Integration**

The Pet Battle application is already configured to send analytics data to Matomo on every connection. You can verify this configuration by checking the `tech-exercise/pet-battle/test/values.yaml` file and looking for the `matomo` settings. Initially, there won't be any data in Matomo, but as we proceed with the A/B deployment and users interact with the application, analytics will start flowing in.

---

## Implementing A/B Deployment

Now that we have analytics in place, let's set up the A/B deployment. We'll create two versions of the Pet Battle application:
- **Version A**: The existing production version (our control)
- **Version B**: The new experimental version (our variant)

We'll start by deploying both versions, then configure traffic splitting to gradually shift users to the new version while monitoring the results.

### Phase 1: Deploy the Experimental Version (B)

**Step 1: Create the Pet Battle B Deployment**

We'll add a new application definition for the experimental version. This will be identical to the production version initially, but we'll make visual changes later to distinguish between the two.

Add the following configuration to `/projects/tech-exercise/pet-battle/test/values.yaml`:

  ```bash
  cat << EOF >> /projects/tech-exercise/pet-battle/test/values.yaml
    # Pet Battle UI - experiment
    pet-battle-b:
      name: pet-battle-b
      enabled: true
      source: http://nexus:8081/repository/helm-charts
      chart_name: pet-battle
      source_ref: 1.0.6 # helm chart version - may need adjusting!
      values:
        image_version: latest # container image version - may need adjusting!
        fullnameOverride: pet-battle-b
        route: false
        config_map: '{
          "catsUrl": "https://pet-battle-api-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
          "tournamentsUrl": "https://pet-battle-tournament-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
          "matomoUrl": "https://matomo-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/",
          "keycloak": {
            "url": "https://keycloak-<TEAM_NAME>-test.<CLUSTER_DOMAIN>/auth/",
            "realm": "pbrealm",
            "clientId": "pbclient",
            "redirectUri": "http://localhost:4200/tournament",
            "enableLogging": true
          }
        }'
  EOF
  ```

> **Note**: Make sure to adjust the `source_ref` (Helm chart version) and `image_version` to match the versions you have available in your Nexus repository.

The existing Pet Battle deployment will serve as our **Version A** (the control group).

### Phase 2: Configure Traffic Splitting

**Step 2: Enable A/B Deployment on the Main Route**

Now we need to configure the main Pet Battle deployment to split traffic between versions A and B. We'll add the `a_b_deploy` configuration to enable traffic splitting.

Edit the `pet-battle` application definition in `/projects/tech-exercise/pet-battle/test/values.yaml` and add the following configuration under the `values` section:

```yaml
      a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'B'
        svc_name: pet-battle-b
```

Your complete `pet-battle` definition should look similar to this (version numbers may differ):

```yaml
  pet-battle:
    name: pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts 
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version
    values:
      image_version: latest # container image version  
      a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'B'
        svc_name: pet-battle-b
      config_map: ...
```

**Step 3: Deploy the Configuration**

Commit and push the changes. Argo CD will detect the updates and deploy both versions:

```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m "🍿 ADD - A & B environments 🍿"
git push
```

Watch the OpenShift UI as Argo CD creates the new deployments. You should see both `pet-battle` and `pet-battle-b` services and deployments.

**Step 4: Verify the Services**

Confirm that both services are properly created:

```bash
oc get svc -l app.kubernetes.io/instance=pet-battle -n ${TEAM_NAME}-test
oc get svc -l app.kubernetes.io/instance=pet-battle-b -n ${TEAM_NAME}-test
```

Both services should be visible and ready to receive traffic.

### Phase 3: Make Visual Changes to Version B

To make the A/B test more visible and demonstrate the traffic splitting, we'll modify the frontend of Version B to have a distinctive green banner.

**Step 5: Modify the Header Component**

Open `/projects/pet-battle/src/app/shell/header/header.component.html` in your IDE and make the following changes:

1. Find the section marked `<!-- Green #009B00 -->`
2. Uncomment the `<nav>` HTML tag with the green background color
3. Remove or comment out the original dark navbar line

The modified section should look like this:

```html
<header>
    <!-- Green #009B00 -->
    <nav class="navbar navbar-expand-lg navbar-dark" style="background-color: #009B00;">
```

This change will make Version B visually distinct with a green banner, making it easy to see which version you're viewing when testing.

**Step 6: Update the Application Version**

To trigger a new build and deployment, update the version in `package.json` at the root of the frontend repository:

```json
{
  "name": "pet-battle",
  "version": "1.6.1",  // <- bump this version number
  "private": true,
  "scripts": ...
}
```

**Step 7: Commit and Push the Changes**

Commit all the frontend changes:

```bash
cd /projects/pet-battle
git add .
git commit -m "🫒 ADD - Green banner 🫒"
git push
```

### Phase 4: Observe the A/B Deployment in Action

**Step 8: Test the Initial Traffic Split**

When Jenkins executes the pipeline, it will:
1. Build the new version with the green banner
2. Update the Argo CD configuration with the new version
3. Deploy the new version to the `pet-battle` service (Version A)
4. Keep `pet-battle-b` running the previous version (for now)

With the current configuration (80% to A, 20% to B), when you access the application, you have a 20% chance of seeing the green banner. Get the route URL:

```bash
oc get route/pet-battle -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

Open the URL in your browser and refresh several times. You should occasionally see the green banner, demonstrating that traffic is being split between the two versions.

> **Tip**: The traffic splitting happens at the Route level, so each request has a 20% chance of being routed to Version B. You may need to refresh multiple times to see the green banner.

### Phase 5: Adjust Traffic Distribution

Now let's experiment with different traffic distributions to see how easy it is to adjust the split.

**Step 9: Increase Traffic to Version B (50/50 Split)**

Let's increase the traffic to Version B to 50% to get more data faster. Update the weight values in `tech-exercise/pet-battle/test/values.yaml`:

```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle.values.a_b_deploy.a_weight='100' pet-battle/test/values.yaml
yq eval -i .applications.pet-battle.values.a_b_deploy.b_weight='100' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m "🏋️‍♂️ service B weight increased to 50% 🏋️‍♂️"
git push
```

> **Note**: In OpenShift Routes, weights are relative, not absolute percentages. Setting both to 100 means a 50/50 split (100:100 = 50%:50%).

> **Remember**: If it's not in Git, it's not real! Always commit your configuration changes.

**Step 10: Test the 50/50 Split**

After Argo CD syncs the changes, test the application again. Open an incognito browser window (to avoid caching) and access the route:

```bash
oc get route/pet-battle -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

With a 50/50 split, you should see the green banner approximately half the time when refreshing the page.

### Phase 6: Complete the Rollout

**Step 11: Redirect All Traffic to Version B**

After monitoring the results in Matomo and confirming that Version B (with the green banner) is performing well, let's complete the rollout by sending 100% of traffic to Version B:

```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle.values.a_b_deploy.a_weight='0' pet-battle/test/values.yaml
yq eval -i .applications.pet-battle.values.a_b_deploy.b_weight='100' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m "💯 service B weight increased to 100 💯"
git push
```

After Argo CD applies the changes, refresh the application page. You should now see the green banner every time, confirming that all traffic is being routed to Version B.

---

## Reviewing Analytics

Don't forget to check **Matomo** to see the analytics data that has been collected during your A/B testing!

This data-driven approach is what makes A/B deployments valuable—you can make informed decisions about which version to keep based on real user behavior and performance metrics.

This GitOps-based approach ensures that all configuration changes are version-controlled, auditable, and reproducible. The traffic splitting can be adjusted at any time by simply updating the weights in the Git repository, and Argo CD will automatically apply the changes.
