## Here be dragons!

![oh-look-a-dragon](../images/oh-look-dragons.png)

### Moving from one cluster to another!

Because all of our code and configuration is in git, we can easily move our whole continuous delivery stack to another OpenShift cluster. This is useful if you wanted to try out all the exercises at a later stage using the code from this run.

As a prerequisite - you will need to have setup TL500 using the previous section [Tooling Installation](99-the-rise-of-the-cluster/1-tooling-installation). Lets cover the steps once you have a cluster and tooling installed to get going with your code.

Lets take our code from `cluster-a` to `cluster-b`.

#### Guided Steps

> Here are the short series of steps to make this work.

1. You will need to git clone the `tech-exercise`, `pet-battle`, `pet-battle-api` repositories to your laptop for safe-keeping after taking this course.

2. Use `vscode` IDE or similar to replace all the occurrances of `apps.cluster-a.com -> apps.cluster-b.com` in the code.

3. Login to `gitlab` and create your ${TEAM_NAME}

4. Let's push our code into the hosted `gitlab` instance in our new cluster:

    ```bash
    export GIT_SERVER=gitlab-ce.apps.cluster-b.com
    export TEAM_NAME=ateam
    ```

    I'm assuming the code is in this folder locally on my laptop, adjust to suit. For each of the repos:

    `Pet-Battle`

    ```bash
    cd ~/git/tl500/pet-battle
    git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/pet-battle.git
    git push -u origin main
    ```

    `Pet-Battle-API`

    ```bash
    cd ~/git/tl500/pet-battle-api
    git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/pet-battle-api.git
    git push -u origin main
    ```

    `Tech-Exercise`

    ```bash
    cd ~/git/tl500/tech-exercise
    git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git
    git push -u origin main
    ```

5. Login to `gitlab` and make sure your newly created projects are set to **public** (they will be private by default).

6. Regenerate the `sealed-secrets` for this new cluster. This assumes we did _not_ migrate the secret master key to the new cluster when setting up (obviously skip this step if you did migrate it!).

    Set `git-auth`

    ```bash
    export GITLAB_USER=<user>
    export GITLAB_PAT=<pat token>

    cat << EOF > /tmp/git-auth.yaml
    kind: Secret
    apiVersion: v1
    data:
      username: "$(echo -n ${GITLAB_USER} | base64 -w0)"
      password: "$(echo -n ${GITLAB_PAT} | base64 -w0)"
    metadata:
      annotations:
        tekton.dev/git-0: https://${GIT_SERVER}
      labels:
        credential.sync.jenkins.openshift.io: "true"
      name: git-auth
    type: kubernetes.io/basic-auth
    EOF

    kubeseal < /tmp/git-auth.yaml > /tmp/sealed-git-auth.yaml \
        -n ${TEAM_NAME}-ci-cd \
        --controller-namespace tl500-shared \
        --controller-name sealed-secrets \
        -o yaml

    cat /tmp/sealed-git-auth.yaml| grep -E 'username|password'
    ```

    Need to apply this to temporarily kick thins off

    ```bash
    oc apply -n ${TEAM_NAME} -f /tmp/git-auth.yaml
    ```

    Set `sonarqube-auth`

    ```bash
    cat << EOF > /tmp/sonarqube-auth.yaml
    apiVersion: v1
    data:
      username: "$(echo -n admin | base64 -w0)"
      password: "$(echo -n admin123 | base64 -w0)"
      currentAdminPassword: "$(echo -n admin | base64 -w0)"
    kind: Secret
    metadata:
      labels:
        credential.sync.jenkins.openshift.io: "true"
      name: sonarqube-auth
    EOF

    kubeseal < /tmp/sonarqube-auth.yaml > /tmp/sealed-sonarqube-auth.yaml \
        -n ${TEAM_NAME}-ci-cd \
        --controller-namespace tl500-shared \
        --controller-name sealed-secrets \
        -o yaml

    cat /tmp/sealed-sonarqube-auth.yaml| grep -E 'username|password|currentAdminPassword'
    ```

    Set `allure-auth`

    ```bash
    cat << EOF > /tmp/allure-auth.yaml
    apiVersion: v1
    data:
      password: "$(echo -n password | base64 -w0)"
      username: "$(echo -n admin | base64 -w0)"
    kind: Secret
    metadata:
      name: allure-auth
    EOF

    kubeseal < /tmp/allure-auth.yaml > /tmp/sealed-allure-auth.yaml \
        -n ${TEAM_NAME}-ci-cd \
        --controller-namespace tl500-shared \
        --controller-name sealed-secrets \
        -o yaml

    cat /tmp/sealed-allure-auth.yaml| grep -E 'username|password'
    ```

    Set `rox-auth`

    ```bash
    export ROX_API_TOKEN=$(oc -n stackrox get secret rox-api-token-tl500 -o go-template='{{index .data "token" | base64decode}}')
    export ROX_ENDPOINT=central-stackrox.apps.cluster-b.com

    cat << EOF > /tmp/rox-auth.yaml
    apiVersion: v1
    data:
      password: "$(echo -n ${ROX_API_TOKEN} | base64 -w0)"
      username: "$(echo -n ${ROX_ENDPOINT} | base64 -w0)"
    kind: Secret
    metadata:
      labels:
        credential.sync.jenkins.openshift.io: "true"
      name: rox-auth
    EOF

    kubeseal < /tmp/rox-auth.yaml > /tmp/sealed-rox-auth.yaml \
        -n ${TEAM_NAME}-ci-cd \
        --controller-namespace tl500-shared \
        --controller-name sealed-secrets \
        -o yaml

    cat /tmp/sealed-rox-auth.yaml | grep -E 'username|password'
    ```

7. Run the basics

    ```bash
    export TEAM_NAME="ateam"
    export CLUSTER_DOMAIN="apps.cluster-b.com"
    export GIT_SERVER="gitlab-ce.apps.cluster-b.com"

    oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u <TEAM_NAME> -p <PASSWORD>
    ```

8. Install ArgoCD

    Add our namespace to the operator env.var:

    ```bash
    run()
    {
      NS=$(oc get subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators \
        -o jsonpath='{.spec.config.env[?(@.name=="ARGOCD_CLUSTER_CONFIG_NAMESPACES")].value}')
      if [ -z $NS ]; then
        NS="${TEAM_NAME}-ci-cd"
      elif [[ "$NS" =~ .*"${TEAM_NAME}-ci-cd".* ]]; then
        echo "${TEAM_NAME}-ci-cd already added."
        return
      else
        NS="${TEAM_NAME}-ci-cd,${NS}"
      fi
      oc -n openshift-operators patch subscriptions.operators.coreos.com/openshift-gitops-operator --type=json \
        -p '[{"op":"replace","path":"/spec/config/env/1","value":{"name": "ARGOCD_CLUSTER_CONFIG_NAMESPACES", "value":"'${NS}'"}}]'
      echo "EnvVar set to: $(oc get subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators \
        -o jsonpath='{.spec.config.env[?(@.name=="ARGOCD_CLUSTER_CONFIG_NAMESPACES")].value}')"
    }
    run
    ```

    Deploy helm chart

    ```bash
    oc new-project ${TEAM_NAME}-ci-cd
    helm repo add redhat-cop https://redhat-cop.github.io/helm-charts

    helm upgrade --install argocd \
    --namespace ${TEAM_NAME}-ci-cd \
    -f tech-exercise/argocd-values.yaml \
    redhat-cop/gitops-operator
    ```

9. Install UJ

    ```bash
    cd tech-exercise
    helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .
    ```

10. Add the integrations and web hooks to gitlab for `tech-exercise`, `pet-battle`, `pet-battle-api` git repos

11. Create new cosign signing keys.

    ```bash
    cd /tmp
    cosign generate-key-pair k8s://${TEAM_NAME}-ci-cd/${TEAM_NAME}-cosign

    cd /projects/tech-exercise
    git add ubiquitous-journey/values-tooling.yaml
    git commit -m  "🔒 ADD - Cosign Jenkins Agent 🔒"
    git push

    cp /tmp/cosign.pub /projects/pet-battle-api/
    cd /projects/pet-battle-api
    git add cosign.pub
    git commit -m  "🪑 ADD - cosign public key for image verification 🪑"
    git push
    ```

12. Kick off builds, make sure they work, fix up any helm chart version mismatches etc.

    ```bash
    cd /projects/pet-battle-api; git commit -m "test" --allow-empty; git push
    cd /projects/pet-battle; git commit -m "test" --allow-empty; git push
    ```

13. 🎉🎉🎉 Celebrate a successful migration to a new cluster 🎉🎉🎉
