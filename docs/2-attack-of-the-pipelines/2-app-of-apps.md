### Deploy App of Apps 
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


our app is made up of N apps. We define the list of apps we want to deploy in the `applications` property in our `pet-battle/test/values.yaml`. Let's add a keycloak service to this list by appending to it as follows. This will take the helm-chart from the repo and apply the additional configuration to it from the `values` section

```yaml
applications:
  # Keycloak
  keycloak:
    name: keycloak
    enabled: true
    source: https://github.com/petbattle/pet-battle-infra.git
    source_path: 'keycloak'
    source_ref: main # helm chart version
    values:
      app_domain: apps.cluster.region.com
      operator: false
```

With the values enabled, let's update the helm chart for our petbattle tooling and now apps also.
```bash
helm upgrade install --namespace ${TEAM_NAME}-ci-cd .
```

Now that the infra for PetBattle is up and running, let's deploy PetBattle itself. 
[TODO] some explanation for folder structure and test/staging env

In your IDE, open up the `pet-battle/test/values.yaml` file and copy the following:

```yaml
  # Pet Battle API
  pet-battle:
    name: pet-battle
    chart_name: pet-battle
    source_ref: 1.0.0 # helm chart version
    values:
      fullnameOverride: pet-battle
      image_version: latest # container image version
      config_map: "'http://pet-battle-api-labs-test.apps.<CLUSTER_URL>'"

  # Pet Battle Frontend
  pet-battle-api:
    name: pet-battle-api
    chart_name: pet-battle-api
    source_ref: 1.0.15 # helm chart version
    values:
      fullnameOverride: pet-battle-api
      image_name: pet-battle-api
      image_version: latest # container image version
      istag:
        enabled: false
      deploymentConfig: false
```

Repeat the same thing for `pet-battle/staging/values.yaml` file in order to deploy the staging environment.

[TODO] Screenshots from ArgoCD