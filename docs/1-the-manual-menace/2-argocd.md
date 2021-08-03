## 🐙 ArgoCD - GitOps Controller
Blah blah blah stuff about ArgoCD and why we use it...

blah blah blah stuff about Operators and what they provide us.

```bash
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts
```

## ArgoCD Basic install

A basic install of ArgoCD
```bash
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  redhat-cop/argocd-operator
```

```bash
oc get pods -w -n ${TEAM_NAME}-ci-cd
```

can login and check _nothing is deployed_

Login and show empty UI

### ArgoCD - Add Repositories at runtime

Post deployment, ArgoCD manages Repositories in a ConfigMap ```oc get cm argocd-cm -o yaml```

We can add `Git|Helm` repositories via `ssh|https`.

Lets add out GitLab repo.

Lets our git creds via a secret (**UJ this**)
```bash
cat <<EOF | oc apply -n ${TEAM_NAME}-ci-cd -f -
apiVersion: v1
data:
  password: <base64 encoded password>
  username: <base64 encoded username>
kind: Secret
metadata:
  annotations:
    tekton.dev/git-0: https://gitlab-ce
  name: git-auth
type: kubernetes.io/basic-auth
EOF
```

Patch the repository list, be sure to use your `GITLAB_URL`
```bash
oc -n ${TEAM_NAME}-ci-cd patch cm argocd-cm --patch "
data:
  repositories: |
    - name: ubiquitous-journey
      url: https://github.com/rht-labs/ubiquitous-journey.git
    - name: redhat-cop
      type: helm
      url: https://redhat-cop.github.io/helm-charts
    - url: https://gitlab-ce.do500-gitlab.${CLUSTER_DOMAIN}/${TEAM_NAME}/team-excercise.git
      type: git
      insecure: false
      insecureIgnoreHostKey: true
      passwordSecret:
        key: password
        name: git-auth
      usernameSecret:
        key: username
        name: git-auth
"
```

### ArgoCD - Add Repositories at install time

**Going the Extra Mile**

We can also add repositories at install time, be sure to use your `GITLAB_URL`.

Lets our git creds via a secret (**UJ this**)
```bash
cat <<EOF | oc apply -n ${TEAM_NAME}-ci-cd -f -
apiVersion: v1
data:
  password: <base64 encoded password>
  username: <base64 encoded username>
kind: Secret
metadata:
  annotations:
    tekton.dev/git-0: https://gitlab-ce
  name: git-auth
type: kubernetes.io/basic-auth
EOF
```

Create our configuration, be sure to use your `GITLAB_URL`.
```bash
cat <<'EOF' > /tmp/initial-repos.yaml
- name: ubiquitous-journey
  url: https://github.com/rht-labs/ubiquitous-journey.git
- name: redhat-cop
  type: helm
  url: https://redhat-cop.github.io/helm-charts
- name: do500-git
  url: https://gitlab-ce.do500-gitlab.${CLUSTER_DOMAIN}/${TEAM_NAME}/team-excercise.git
  type: git
  insecure: true
  insecureIgnoreHostKey: true
  passwordSecret:
    name: git-auth
    key: password
  usernameSecret:
    name: git-auth
    key: username
EOF

cat <<'EOF' > /tmp/initial-creds.yaml
- name: git-auth
  passwordSecret:
    name: git-auth
    key: password
  usernameSecret:
    name: git-auth
    key: username
  type: git
  url: https://gitlab-ce.do500-gitlab.${CLUSTER_DOMAIN}
EOF
```

Reinstall ArgoCD using new initial settings:
```bash
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  --set argocd_cr.initialRepositories="$(cat /tmp/initial-repos.yaml)" \
  --set argocd_cr.repositoryCredentials="$(cat /tmp/initial-creds.yaml)" \
  redhat-cop/argocd-operator
```

### Deploy Microsite via ArgoCD (into new namespace?)

^ this is all well and good, but we want to do GIT OPS !
