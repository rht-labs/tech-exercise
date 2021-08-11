### Tekton Pipeline 
blah blah blah

`TODO`
- [ ] Something something what is Tekton (and OpenShift Pipelines)
- [ ] Explain what this Tekton pipeline is going to do

#### Deploying the Tekton Objects

1. Create a repo in GitLab under `<YOUR_TEAM_NAME>` group called `pet-battle-api`. Then fork the PetBattle API.

```bash
cd /projects
git clone https://github.com/rht-labs/pet-battle-api.git && cd pet-battle-api
git remote set-url origin https://gitlab-ce.${CLUSTER_DOMAIN}/${TEAM_NAME}/pet-battle-api.git
git branch -M main
git push -u origin main
```

2. Edit `ubiquitous-journey/values-tooling.yaml` deploy Tekton Pipelines code. Remeber to replace the `CLUSTER_DOMAIN` and `TEAM_NAME` with your own.

```yaml
  # Tekton Pipelines
  - name: tekton-pipeline
    enabled: true
    source: "https://gitlab-ce.<CLUSTER_DOMAIN>/<TEAM_NAME>/tech-exercise.git"
    source_ref: main
    source_path: tekton
    values:
      team: <TEAM_NAME>
      cluster_domain: <CLUSTER_DOMAIN>
```

3. Tekton will push changes to our Helm Chart to Nexus as part of the pipeline. Originally we configured our App of Apps to pull from a different chart repository so we also need to update out Pet Battle `pet-battle/test/values.yaml` file to point to the Nexus chart repository deployed in OpenShift. Update the `source` as shown below for the `pet-battle-api`:
<pre>
  # Pet Battle Apps
  pet-battle-api:
    name: pet-battle-api
    enabled: true
    source: <strong>http://nexus:8081/repository/helm-charts</strong>
    chart_name: pet-battle-api
    source_ref: 1.1.0 # helm chart version
    values:
      image_name: pet-battle-api
      image_version: latest # container image version
</pre>

4. Update git
```bash
# git add, commit, push your changes..
cd /projects/tech-exercise
git add .
git commit -m  "🍕 ADD - tekton pipelines config 🍕" 
git push 
```

5. Add webhook to GitLab `pet-battle-api` project
- fill in the `URL` based on this route
```bash
oc -n ${TEAM_NAME}-ci-cd get route webhook --template='{{ .spec.host }}'
```
![gitlab-webhook-trigger.png](images/gitlab-webhook-trigger.png)
- select `Push Events`, leve the branch empty for now
- select `SSL Verification`
- Click `Add webhook` button.

You can test the webhook works from GitLab.

![gitlab-test-webhook.png](images/gitlab-test-webhook.png)


?> **Tip** You can enable debug log info for your tekton webhook pod by setting
```bash
oc -n ${TEAM_NAME}-ci-cd edit cm config-logging-triggers
```
<pre>
// set log level
data:
  loglevel.eventlistener: debug
</pre>


6. Trigger pipeline via webhook by checking in some code for Pet Battle API. Lets change the application versions.

- Edit pet-battle-api `pom.xml` and update the `version` number
```xml
    <artifactId>pet-battle-api</artifactId>
    <version>1.2.1</version>
```
The pipeline will update the `chart/Chart.yaml` with these versions for us.

Update git
```bash
# git add, commit, push your changes..
cd /projects/pet-battle-api
git add .
git commit -m  "🍕 UPDATED - pet-battle-version to 1.1.2 🍕" 
git push 
```


🪄 OBSERVE PIPELINE RUNNING :D 

#### TODO
- [ ] add in full explanations of all the steps