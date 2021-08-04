### Deploy App of Apps 
Blah Blah .. this is what app of apps pattern is, what application sets are etc etc

Deploy an piece of supporting tech or "infra" for PB - keycloak in `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml`
blah blah blah, this is keyclock required by PB for auth.... We will demonstrate deploying it using a GitOps parrtern which is repeatable

something something app of apps, what it is why we use it
Now let's enable app-of-apps definition for petbatlle deplopments in test and staging. Open `values.yaml` file at the root of this project and swap `enabled: false` to `enabled: true` as shown below:

<pre>
  # Test app of app
  - name: test-app-of-pb
<strong>    enabled: true</strong>
    helm_values:
      - pet-battle/test/values.yaml

  # Staging App of Apps
  - name: staging-app-of-pb
<strong>    enabled: true</strong>
    helm_values:
      - pet-battle/staging/values.yaml
</pre>


our app is made up of N apps. We define the list of apps we want to deploy in the `applications` property in our `pet-battle/test/values.yaml`. Let's add a keycloak service to this list by appending to it as follows. This will take the helm-chart from the repo and apply the additional configuration to it from the `values` section. Make sure to replace <CLUSTER_DOMAIN> with your value.

```yaml
applications:
  # Keycloak
  keycloak:
    name: keycloak
    enabled: true
    source: https://github.com/petbattle/pet-battle-infra
    source_ref: main
    source_path: keycloak
    values:
      app_domain: <CLUSTER_DOMAIN>
      ignoreHelmHooks: true
```

Its not real unless its in git
```bash
# git add, commit, push your changes..
git add .
git commit -m  "🐰 ADD - keycloak to test 🐰" 
git push 
```

With the values enabled, let's update the helm chart for our petbattle tooling and now apps also.
```bash
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .
```

`FIXME` - Now we Rinse and Repeat for the other infra components for `infinispan, grafana, cert-utils`

```yaml
applications:
  # Infnispan
  infinispan:
    name: infinispan
    enabled: true
    source: https://github.com/petbattle/pet-battle-infra
    source_ref: main
    source_path: infinispan
    values:
      ignoreHelmHooks: true
```

Its not real unless its in git
```bash
# git add, commit, push your changes..
git add .
git commit -m  "🐰 ADD - infinispan to test 🐰" 
git push 
```


Now that the infra for PetBattle is up and running, let's deploy PetBattle itself. 
[TODO] some explanation for folder structure and test/staging env

In your IDE, open up the `pet-battle/test/values.yaml` file and copy the following:

```yaml
  # Pet Battle Apps
  pet-battle-api:
    name: pet-battle-api
    enabled: true
    source: http://nexus:8081/repository/helm-charts # https://petbattle.github.io/helm-charts/
    chart_name: pet-battle-api
    source_ref: 1.1.0 # helm chart version
    values:
      image_name: pet-battle-api
      image_version: latest # container image version

  pet-battle:
    name: pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts # https://petbattle.github.io/helm-charts/
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version
    values:
      image_version: latest # container image version
```

The front end needs to have some configuration applied to it. This should be packaged up in the helm chart or baked into the image - butttt we should really apply configuration as *code*. We should build our apps once so they can be initialised in many environments with supplied configuration. For the Frontend, this means supplying the information to where the API live. We use ArgoCD to manage our application deployments, so hence we should update the definition for the front end as such.
```bash
cat << EOF >> pet-battle/test/values.yaml
      config_map: '{
        "catsUrl": "https://pet-battle-api-${TEAM_NAME}-test.${CLUSTER_DOMAIN}",
        "tournamentsUrl": "https://pet-battle-tournament-${TEAM_NAME}-test.${CLUSTER_DOMAIN}",
        "matomoUrl": "https://matomo-${TEAM_NAME}-ci-cd.${CLUSTER_DOMAIN}/",
        "keycloak": {
          "url": "https://keycloak-${TEAM_NAME}-test.${CLUSTER_DOMAIN}/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'
EOF
```

The `pet-battle/test/values.yaml` file should now look something like this (but with your team name and domain)
<pre>
  # Pet Battle Frontend
  pet-battle:
    name: pet-battle
    enabled: true
    source: https://github.com/petbattle/pet-battle-infra.git
    source_ref: 1.0.0 # helm chart version
    values:
      image_version: latest # container image version
      config_map: '{
        "catsUrl": "https://pet-battle-api-biscuits-test.apps.example.com",
        "tournamentsUrl": "https://pet-battle-tournament-biscuits-test.apps.example.com",
        "matomoUrl": "https://matomo-biscuits-ci-cd.apps.example.com/",
        "keycloak": {
          "url": "https://keycloak-biscuits-test.apps.example.com/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'
</pre>

Repeat the same thing for `pet-battle/staging/values.yaml` file in order to deploy the staging environment, and push your changes to the repo.

```bash
git add ...
```

[TODO] Screenshots from ArgoCD