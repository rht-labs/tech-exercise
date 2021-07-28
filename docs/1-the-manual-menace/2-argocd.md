## 🐙 ArgoCD - GitOps Controller
Blah blah blah stuff about ArgoCD and why we use it...

blah blah blah stuff about Operators and what they provide us.

```bash
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts
```

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

Deploy Microsite via ArgoCD (into new namespace?)

^ this is all well and good, but we want to do GIT OPS !
