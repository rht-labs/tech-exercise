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
cat <<'EOF' > tekton/templates/tasks/image-signing.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-signing
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
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
      type: string
  steps:
    - name: image-signing
      image: quay.io/openshift/origin-cli:4.8
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
        set +x
        curl -skL -o /tmp/cosign https://github.com/sigstore/cosign/releases/download/v$(params.COSIGN_VERSION)/cosign-linux-amd64
        chmod -R 775 /tmp/cosign

        oc registry login
        echo $COSIGN_PRIVATE_KEY | sed -E 's/(-+(BEGIN|END) ENCRYPTED COSIGN PRIVATE KEY-+) *| +/\1\n/g' > /tmp/cosign.key
        /tmp/cosign sign -key /tmp/cosign.key $(params.IMAGE)
EOF
```


2. Let's add this task into pipeline. Edit `tekton/pipelines/maven-pipeline.yaml` and copy below yaml where the placeholder is.

```yaml
    # COSIGN IMAGE SIGN 
    - name: image-signing
      runAfter:
      - verify-deployment
      taskRef:
        name: image-signing
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: "$(tasks.bake.results.IMAGE)"
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
```

3. It's not real unless it's in git, right?

```bash
# git add, commit, push your changes..
git add .
git commit -m  "👨‍🎤 ADD - image-signing-task 👨‍🎤" 
git push
```

4. Store the public key in `pet-battle-api` repository for anyone who would like to verify our images. This push will also trigger the pipeline.

```bash
mv cosign.pub /projects/pet-battle-api
rm cosign.key
cd /projects/pet-battle-api
git add  cosign.pub
git commit -m  "🪑 ADD - cosign public key for image verification 🪑"
git push
```

🪄 Observe the **pet-battle-api** pipeline running with the **image-sign** task.

After the task succesfully finish, go to OpenShift UI > Builds > ImageStreams and select `pet-battle-api`. You'll see a tag ending with `.sig` which shows you that this is image signed. 
![cosign-image-signing](images/cosign-image-signing.png)

5. Let's verify the signed image with the public key:

```bash
cd /projects/pet-battle-api
oc registry login
cosign verify -key cosign.pub default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-cd-cd/pet-battle-api
```

The output should be like:

```bash
Verification for default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-ci-cd/pet-battle-api --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key
  - Any certificates were verified against the Fulcio roots.
{"critical":{"identity":{"docker-reference":"default-route-openshift-image-registry.<CLUSTER_DOMAIN>/<TEAM_NAME>-ci-cd/pet-battle-api"},"image":{"docker-manifest-digest":"sha256:ec332c568ef608b6f1d2d179d9ac154523fbe412b4f893d76d49d267a7973fea"},"type":"cosign container image signature"},"optional":null}
```