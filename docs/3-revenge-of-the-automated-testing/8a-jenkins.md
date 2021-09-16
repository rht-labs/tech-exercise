### Extend Jenkins Pipeline with Image Signing

1. Add a new Jenkins agent with `cosign` commandline in it. Open up `ubiquitous-journey/values-tooling.yaml` and under `Jenkins` add `jenkins-agent-cosign` to the list.

```yaml
        # default names, versions, repo and paths set on the template
        - name: jenkins-agent-npm
        - name: jenkins-agent-mvn
        - name: jenkins-agent-helm
        - name: jenkins-agent-argocd
        - name: jenkins-agent-cosign # add this one
```

```bash
cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🔒 ADD - Cosign Jenkins Agent 🔒" 
git push
```


3. Add a new stage into Jenkinsfile with cosign steps. Image signing should run after image build. Copy the below block into the right placeholder:

```groovy
		stage("🔏 Image Signing") {
			agent { label "jenkins-agent-cosign" }
			steps {
				script {
                    sh '''
                    oc registry login
                    cosign sign -key k8s://${TEAM_NAME}-ci-cd/${TEAM_NAME}-cosign `oc registry info`/${DESTINATION_NAMESPACE}/${APP_NAME}:${VERSION}
                    '''
				}
			}
		}

```

4. Store the public key in `pet-battle` repo for anyone who would like to verify our images, alongside the Jenkinsfile changes. This push will trigger a Jenkins job for build as well.

```bash
cp /tmp/cosign.pub /projects/pet-battle/
cd /projects/pet-battle
git add cosign.pub Jenkinsfile
git commit -m  "⛹️ ADD - cosign public key for image verification and Jenkinsfile updated ⛹️"
git push
```

🪄 Obeserve the **pet-battle** pipeline running with the **image-sign** stage.

After the pipeline succesfully finish, go to OpenShift UI > Builds > ImageStreams and select `pet-battle`. You'll see a tag ending with `.sig` which shows you that this is image signed. 
![cosign-image-signing](images/cosign-image-signing.png)

[TODO] update the screenshot

5. Let's verify the signed image with the public key:

```bash
cd /projects/pet-battle
oc registry login
cosign verify -key cosign.pub default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-cd-cd/pet-battle
```

The output should be like:

```bash
Verification for default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-ci-cd/pet-battle --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key
  - Any certificates were verified against the Fulcio roots.
{"critical":{"identity":{"docker-reference":"default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-ci-cd/pet-battle"},"image":{"docker-manifest-digest":"sha256:ec332c568ef608b6f1d2d179d9ac154523fbe412b4f893d76d49d267a7973fea"},"type":"cosign container image signature"},"optional":null}
```