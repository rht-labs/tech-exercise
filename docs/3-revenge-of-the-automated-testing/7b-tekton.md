### Extend Tekton Pipeline with Image Signing

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
          annotations:
            tekton.dev/git-0: https://gitlab-ce.<CLUSTER_DOMAIN>
          labels:
            credential.sync.jenkins.openshift.io: "true"
          data:
            cosign.key: AgBH...
            password: AgA1bg...
  ```

..and push the changes:

```bash
cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🔒 ADD - cosign private key sealed secret 🔒" 
git push
```

### Sign Images
1. Add a task into our codebase to sign our built images.

```bash
cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/cosign-image-sign.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: cosign-image-sign
spec:
  workspaces:
    - name: output
  params:
    - name: COSIGN_SECRET
      type: string
      description: Secret containing the private key and password for image signing
      default: <TEAM_NAME>-cosign
    - name: IMAGE
      type: string
      description: Full name of image to sign (example -- gcr.io/rox/sample:5.0-rc1)
    - name: COSIGN_VERSION
      type: string
      description: Version of cosign CLI
      default: 1.0.0
  steps:
    - name: cosign-image-sign
      image: quay.io/podman/stable:latest
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      env:
        - name: COSIGN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $(params.COSIGN_SECRET)
              key: password
        - name: COSIGN_PRIVATE_KEY
          valueFrom:
            secretKeyRef:
              name: $(params.COSIGN_SECRET)
              key: cosign.key
      script: |
        #!/usr/bin/env bash
        curl -skL -o /tmp/cosign https://github.com/sigstore/cosign/releases/download/v$(params.COSIGN_VERSION)/cosign-linux-amd64
        chmod -R 775 /tmp/cosign

        podman login -u openshift -p $(cat /run/secrets/kubernetes.io/serviceaccount/token) default-route-openshift-image-registry.apps.hivec.sandbox941.opentlc.com --authfile ~/.docker/config.json
        echo $COSIGN_PRIVATE_KEY |   sed -E 's/(-+(BEGIN|END) ENCRYPTED COSIGN PRIVATE KEY-+) *| +/\1\n/g' > /tmp/cosign.key
        /tmp/cosign sign -key /tmp/cosign.key $(params.IMAGE)
EOF
```


2. Let's add this task into pipeline. Edit `tekton/pipelines/maven-pipeline.yaml` and copy below yaml where the placeholder is.

```yaml
    # COSIGN IMAGE SIGN 
    - name: image-sign
      runAfter:
      - bake
      taskRef:
        name: cosign-image-sign
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: "$(tasks.bake.results.IMAGE)"
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
```

3. Its not real unless its in git

```bash
# git add, commit, push your changes..
git add .
git commit -m  "👨‍🎤 ADD - cosign-image-sign-task 👨‍🎤" 
git push
```

4. Store the public key in `pet-battle-api` repo for anyone who would like to verify our images. This push will also trigger the pipeline.

```bash
mv cosign.pub /projects/pet-battle-api
rm cosign.key
cd /projects/pet-battle-api
git add  cosign.pub
git commit -m  "🪑 ADD - cosign public key for image verification 🪑"
git push
```

🪄 Obeserve the **pet-battle-api** pipeline running with the **image-sign** task.

After the task succesfully finish, go to OpenShift UI > Builds > ImageStreams and select `pet-battle-api`. You'll see a tag ending with `.sig` which shows you that this is image signed. 
![cosign-image-signing](images/cosign-image-signing.png)