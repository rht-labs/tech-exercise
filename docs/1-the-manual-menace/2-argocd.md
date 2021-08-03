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

### ArgoCD - More comprehensive initial install

Post deployment, ArgoCD manages Repositories in a ConfigMap ```oc get cm argocd-cm -o yaml```

We can set initial Repositories up at install time.

Lets reinstall ArgoCD to use our gitlab. We need a secret (**UJ this**)
```bash
GITLAB_PASSWORD=<gitlab user>
GITLAB_USER=<gitlab password>

cat <<EOF | oc apply -n ${TEAM_NAME}-ci-cd -f -
apiVersion: v1
data:
  password: "$(echo -n ${GITLAB_PASSWORD} | base64)"
  username: "$(echo -n ${GITLAB_USER} | base64)"
kind: Secret
metadata:
  annotations:
    tekton.dev/git-0: https://gitlab-ce
  name: git-auth
type: kubernetes.io/basic-auth
EOF
```

Create the ArgoCD default settings in YAML file format - change you `GITLAB_URL's` to match:
```bash
cat <<'EOF' > /tmp/initial-repos.yaml
- name: ubiquitous-journey
  url: https://github.com/rht-labs/ubiquitous-journey.git
- name: redhat-cop
  type: helm
  url: https://redhat-cop.github.io/helm-charts
- name: do500-git
  url: https://gitlab-ce.apps.hivec.sandbox1243.opentlc.com/ateam/team-excercise.git
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
  url: https://gitlab-ce.apps.hivec.sandbox1243.opentlc.com
EOF
```

Reinstall ArgoCD
```bash
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  --set argocd_cr.initialRepositories="$(cat /tmp/initial-repos.yaml)" \
  --set argocd_cr.repositoryCredentials="$(cat /tmp/initial-creds.yaml)" \
  redhat-cop/argocd-operator
```

Deploy Microsite via ArgoCD (into new namespace?)

^ this is all well and good, but we want to do GIT OPS !
