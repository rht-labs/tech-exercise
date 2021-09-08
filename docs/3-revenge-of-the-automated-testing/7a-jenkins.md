### Extend Jenkins Pipeline with Image Signing

1. Generate a keypair to use for signing images. It expects you to enter a password for private key. Feel free to select something but make sure to remember for the next steps :) 

```bash
cosign generate-key-pair
```

<pre>
$ cosign generate-key-pair
Enter password for private key: 
Enter again: 
Private key written to cosign.key
Public key written to cosign.pub
</pre>

Now you generated two files (one private key, one public key). Private key is used to sign the image and public key is used to verify. You need to share your public key for people to verify images but private one should be kept in a vault or at least sealed before storing publicly.

For this exercise, we can use SealedSecret approach that we used in the first exercise. 

2. Run below command to generate a secret template with your private key and your password. Open up a new file in your IDE and copy this content. 

```bash
sed -i -e 's/^/    /' cosign.key 
export COSIGN_PRIVATE_KEY=`cat cosign.key` 
```

```bash
export COSIGN_PASSWORD=<YOUR_COSIGN_PASSWORD>
```


```bash
cat << EOF > /tmp/cosign-private-key.yaml
apiVersion: v1
stringData:
  cosign.key: |-
${COSIGN_PRIVATE_KEY}
  password: ${COSIGN_PASSWORD}
kind: Secret
metadata:
  name: ${TEAM_NAME}-cosign
type: Opaque
EOF
```

2. Use `kubeseal` commandline to seal the secret definition.

```bash
kubeseal < /tmp/cosign-private-key.yaml > /tmp/sealed-cosign-private-key.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace do500-shared \
    --controller-name sealed-secrets \
    -o yaml
```

3. We want to grab the results of this sealing activity, in particular the `encryptedData`.

```bash
cat /tmp/sealed-cosign-private-key.yaml | grep -E 'cosign.key|password'
```
<pre>
    cosign.key: AgAj3JQj+EP23pnzu...
    password: AgAtnYz8U0AqIIaqYrj...
</pre>

4. In `ubiquitous-journey/values-tooling.yaml` extend the Sealed Secrets entry. Copy the output of `cosign.key` and `password` from the previous command and update the values. Make sure you indent the data correctly.

```yaml
        - name: <TEAM_NAME>-cosign
          type: Opaque
          labels:
            credential.sync.jenkins.openshift.io: "true"
          data:
            cosign.key: AgAj3JQj+EP23pnzu...
            password: AgAtnYz8U0AqIIaqYrj...
  ```

..and push the changes:

```bash
cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🔒 ADD - cosign private key sealed secret 🔒" 
git push
```

### Sign Images
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
                    set +x
                    oc registry login
                    export COSIGN_PASSWORD=`oc get secret magic-cosign -o go-template --template="{{.data.password |base64decode}}" `
                    oc get secret magic-cosign -o go-template --template='{{index .data "cosign.key" | base64decode}}' > /tmp/cosign.key
                    cosign sign -key /tmp/cosign.key ${DESTINATION_NAMESPACE}/${APP_NAME}:${VERSION}
                    '''
				}
			}
		}

```

4. Store the public key in `pet-battle` repo for anyone who would like to verify our images, alongside the Jenkinsfile changes. This push will trigger a Jenkins job for build as well.

```bash
mv cosign.pub /projects/pet-battle
rm cosign.key
cd /projects/pet-battle
git add  cosign.pub Jenkinsfile
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