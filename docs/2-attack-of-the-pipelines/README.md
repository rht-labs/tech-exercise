# Exercise 2 - Attack of the Pipelines

- [] Add Intro to section
- [] Add Learning Objectives
- [] Add Big Picture?

## 🔨 Tools used in this exercise!
* [SealedSecrets]
* [Jenkins]
* [Nexus]
* [Tekton]

## Deploy PetBattle

[TODO] Little introduction to PetBattle


### 1. SealedSecrets 
* [copy + paste from previous ex]


### 2. Deploy App of Apps 
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


our app is made up of n apps. We define the list of apps we want to deploy int ehapplications array. Let's add a keycloak service to this list by appending

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
      operartor: false
```

With the values enabled, let's update the helm chart for our petbattle tooling and now apps also.a
```bash
helm upgrade install --namespace ${TEAM_NAME}-ci-cd .
```


### 3 - The Pipelines 

Split into groups and each group does
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile / Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml` with services information. That's where two teams integrate their works.
- By updating version files (pom.xml etc), kick the pipelines
- Question: should we only leave 'master/main' branch deployment
[TODO] decide what to leave out from Jenkinsfile