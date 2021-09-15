### A/B Deployments
> Something something A/B deployment
[TODO] configmap - URL update

[OpenShift Docs](https://docs.openshift.com/container-platform/4.8/applications/deployments/route-based-deployment-strategies.html#deployments-ab-testing_route-based-deployment-strategies) is pretty good at showing an example of how to do a manual A/B deployment. But in the real world you'll want to automate this by increasing the load of the alternative service based on some tests or other metric. Plus this is GITOPS! So how do we do a A/B with all of this automation and new tech, let's take a look with our Pet Battle UI!

[TODO - ADD the DIAGRAM for what's happening]

- Let's explore `route` definition.
[TODO - Insert existing route definition and introduce alternateBackends]

1. First let's deploy our experiment we want to compare -  let's call this `A` and we'll use our existing Pet Battle deployment as `B`
```bash
cat << EOF > /projects/tech-exercise/pet-battle/test/values.yaml
  # Pet Battle UI - experiment
  pet-battle-b:
    name: pet-battle-b
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.1.0 # helm chart version
    values:
      image_version: latest # container image version
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

2. Extend the cofiguration for the Pet Battle deployment by adding the `a_b_deploy` properties to the values section. Copy the below lines under `pet-battle` application definition in `/projects/tech-exercise/pet-battle/test/values.yaml` file.
```yaml
      a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'a'
        svc_name: pet-battle-b
```
The `pet-battle` definition in `test/values.yaml` should look something like this (the version numbers may be different)
<pre><code class="language-yaml">
  pet-battle:
    name: pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts 
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version
    values:
      image_version: latest # container image version  
      <strong>a_b_deploy:
        a_weight: 80
        b_weight: 20 # 20% of the traffic will be directed to 'b'
        svc_name: pet-battle-b</strong>
      config_map: ...
</code></pre>

3. Git commit the changes and in OpenShift UI, you'll see two new deployments are coming alive.
```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m  "🍿 ADD - A & B environments 🍿"
git push
```

4. Verify if you have the both service definition.
```bash
oc get svc -l app.kubernetes.io/name=pet-battle -n ${TEAM_NAME}-test
oc get svc -l app.kubernetes.io/name=pet-battle-b -n ${TEAM_NAME}-test
```

5. Before verify the traffic redirection, let's make a simple application change to make this more visual. In the frontend, we'll change the banner along the top of the app. In your IDE, open `pet-battle/src/app/shell/header/header.component.html`. Uncomment the `<nav>` HTML Tag under the `<!-- Green #009B00 -->`.

<strong>Remove the line</strong> for the original `<nav class="navbar navbar-expand-lg navbar-dark bg-dark">`. It appears like this:
```html
<header>
    <!-- Green #009B00 -->
    <nav class="navbar  navbar-expand-lg navbar-dark" style="background-color: #009B00;">
```

6. Bump the version of the application to trigger a new release by updating the `version` in the `package.json` at the root of the frontend's repository
<pre><code class="language-yaml">
"name": "pet-battle",
"version": "1.6.1", <- bump this
"private": true,
"scripts": ...
</code></pre>

7. Commit all these changes:
```bash
cd /projects/pet-battle
git add .
git commit -m "🫒 ADD - Green banner 🫒"
```

8. When Jenkins executes, it'll bump the version in ArgoCD configuration. ArgoCD triggers the new version deployment while `pet-battle-b` is still running in the previous version. 

If you open up `pet-battle` in your browser, 20 percent of the traffic is going to `b`. You have a little chance to see the green banner.
```bash
oc get route/pet-battle -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

9. Now let's redirect 50% of the traffic to `B`, that means that only 50% of the traffic will go to `A`. So you need to update `weight` value in `tech-exercise/pet-battle/test/values.yaml` file.
And as always, push it to the Git repository - <strong>Because if it's not in Git, it's not real!</strong>
```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-a.values.a_b_deploy.a_weight='100' pet-battle/test/values.yaml
yq eval -i .applications.pet-battle-a.values.a_b_deploy.b_weight='100' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m  "🏋️‍♂️ service B weight increased to 80 🏋️‍♂️"
git push
```

10. Open an incognito browser and connect to the same URL. You'll have 50% chance to get a green banner.
```bash
oc get route/pet-battle -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

11. Apparently people like green banner on PetBattle UI! Let's redirect all traffic to service `A`. Yes, for that we need to make weight 0 for service `B`. If you refresh the page, you should only see the green banner.
```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-a.values.a_b_deploy.a_weight='100' pet-battle/test/values.yaml
yq eval -i .applications.pet-battle-a.values.a_b_deploy.b_weight='0' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m  "💯 service B weight increased to 100 💯"
git push
```
### A/B and Analytics
> something somethign matomo / google analytics

1. Deploy matomo via our argocd stuff
2. make app change for the experiment we want to run eg upvote / downvote
3. show data in the matomo server
