# Exercise 1 - The Manual Menace

- [] Add Intro to section
- [] Add Learning Objectives
- [] Add Big Picture?

## 🔨 Tools used in this exercise!
* [Helm](https://helm.sh/) - one line definition
* [ArgoCD](https://argoproj.github.io/argo-cd/) - one line definition
* [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) - one line definition

### The Basics - Login & Helm
1. Login to your CRW envionemnt [TODO]

2. Setup your team name in the env:
```bash
# setup for commands
echo TEAM_NAME="biscuits" >> ~/.bashrc
```
```bash
source ~/.bashrc
```

3. Check you can connect to OpenShift
```bash
# check you can access the cluster
oc login ..
```
```bash
# check you have permissions to do stuff
oc new-project ${TEAM_NAME}-ci-cd
```

4.  TODO - Familiarise yourself with some basic helm...
    * thinking add some random chart / website / app eg Residency Microsite? 
    * change values eg defaults and then override on the command line
    * show values changed?


### 1. ArgoCD - GitOps Controller
Blah blah blah stuff about ArgoCD and why we use it...

blah blah blah stuff about Operators and what they provide us.

```bash
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts
```

```bash
helm upgrade --install argocd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  redhat-cop/argocd-operator
```

```bash
oc get pods -w -n ${TEAM_NAME}-ci-cd
```

can login and check _nothing is deployed_

Login and show empty UI

Deploy Microsite via ArgoCD (into new namespace?)

^ this is all well and good, but we want to do GIT OPS !


### 2. Ubiquitous Journey
blah blah what it is, why we use it
Extensible, traceable, auditable ...

```bash
# create a Group in GitLab for your team

# create a repo in GitLab in that group

# clone repo to your IDE
```

Take a walk in values-tooling.yaml file...
* Boostrap projects 
* Jenkins
Take a walk in values.yaml file... [pb enabled false]

```yaml
# update your values.yaml in the root file accordingly
source: "https://gitlab-ce.apps.cluster.example.com/<YOUR_TEAM_NAME>/tech-exercise.git"
team: <YOUR_TEAM_NAME>
```

update your `ubiquitous-journey/values-tooling.yaml` to change <YOUR_TEAM_NAME> in the bootstrap section
<pre class="language-yaml">
...
        - name: jenkins
          kind: ServiceAccount
          role: admin
          namespace: biscuits-ci-cd
      namespaces:
        - name: biscuits-ci-cd
          bindings: *binds
        - name: biscuits-dev
          bindings: *binds
        - name: biscuits-test
          bindings: *binds
        - name: biscuits-staging
          bindings: *binds
...
</pre>

```bash
# git add, commit, push your changes..
git add .
git commit -m  "🦆 ADD - correct project names 🦆" 
git push 
```

install all the tooling in UJ (only bootstrap, and Jenkins at this stage..)
```bash
helm upgrade install .
```
show namespaces & Jenkins spinning up via ArgoCD 

show resources in the cluster
```bash
oc get projects | grep ${TEAM_NAME}
```
```bash
oc get pods -n ${TEAM_NAME}-ci-cd
```

TODO - fix bootstrap for dummy-sa (sort of did at the time being)
### 4. Extend UJ with a another tool, eg Nexus 
- (emphasize IF IT'S NOT GIT, IT'S NOT REAL!!! mantra)

Add more tools to the UJ for ex, nexus for managing our artifacts

update your `ubiquitous-journey/values-tooling.yaml` to include Nexus with some sensible defaults 
```yaml
  # Nexus
  - name: nexus
    enabled: true
    source: https://redhat-cop.github.io/helm-charts
    chart_name: sonatype-nexus
    source_ref: "0.0.15"
    values:
      service:
        name: nexus
```

```bash
git add, commit, push..
```

observe ArgoCD that nexus spins up and connect to Nexus itself to verify

### 5. Validate our GitOps
1. Make a change in the UI and have it overwritten - GOOO GOOOO GITOPS 💪
2. Make same change in UJ to have it persisted
   1. Add some env var to the Jenkins deployment


### 6. Sealed Secrets

Blah blah blah - soemthing about SS and why we use it....
public repos with private secrets
devops is hard, secure devops is harder....

these secrets are used by our pipeline in the next exercise.

lets start by sealing our token for accessing git. Update the `<YOUR_USERNAME>` and `<YOUR_PASSWORD>` below with the ones provided by your instructor and run the command. This will generate a kube secret in `tmp`
```bash
cat << EOF > /tmp/git-auth.yaml       
---
apiVersion: v1
kind: Secret
metadata:
  name: git-auth
  labels:
    credential.sync.jenkins.openshift.io: "true"
type: "kubernetes.io/basic-auth"
stringData:
  password: "<YOUR_PASSWORD>"
  username:  "<YOUR_USERNAME>"
EOF
```

with the non-sealed secret local, let's seal up. 
tell people what kubeseal is
```bash
# use kubeseal to seal the secret
kubeseal < /tmp/git-auth.yaml > /tmp/sealed-git-auth.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace shared-do500 \
    --controller-name sealed-secrets \
    -o yaml
```
```bash
# verify its results
cat /tmp/sealed-git-auth.yaml 
```

We should now see the secret is sealed, so it is safe for us to store in our repository. It should look something a bit like this, but with longer password and username output.
[TODO] - mark this snipped as NOT TO BE COPIED
<pre>
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: git-auth
  namespace: biscuits-ci-cd
spec:
  encryptedData:
    password: AgAj3JQj+EP23pnzu...
    username: AgAtnYz8U0AqIIaqYrj...
...
</pre>

We want to grab the results of this sealing activity, in particular the `encryptedData`

```bash
cat /tmp/sealed-git-auth.yaml | grep -E 'username|password'
```
<pre>
    password: AgAj3JQj+EP23pnzu...
    username: AgAtnYz8U0AqIIaqYrj...
</pre>

In `ubiquitous-journey/values-tooling.yaml` create an entry in the values section of the Jenkins deployment for `sealed_secrets`. This can be added below the nexus secret as shown below. Copy the output of `username` and `password`  from the previous command and update the values.
```yaml
...
      source_secrets:
        - name: nexus-password
          username: admin
          password: admin123
      sealed_secrets:
        - name: git-auth
          password: AgB5zWuxTNzuvwP34eoX...
          username: AgCHtknToI83LtEO9Dm...
```

Now that we update the file, we need to push the changes to our repository for ArgoCD to detect the update. Because it is GitOps :)

```bash
git add ubiquitous-journey/values-tooling.yaml
git commit -m "🕵🏻‍♂️ Sealed secret of Git user creds is added 🔎"
git push
```

🪄 Log in to ArgoCD - you should now see the SealedSecret unsealed as a regular k8s secret

🪄 Log in to Jenkins -> Configuration -> Credentials to view git-auth credential is there.

## Tasks for go getters
### 1. Extend 🔥🦄
- Add $SOMETHING from the redhat-cop/helm-charts repo to the UJ eg Hoverfly, Zalenium or something else
[todo links to example charts]

### 2. Envirnonment
- use the learnings from above to create a `uat` environment from code.

### 3. Make ArgoCD more secure
- Use the chart Readme in ()[] to create a private repository group and secret to access charts from. 

