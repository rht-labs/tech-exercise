
## Deploy ArgoCD - our GitOps Controller
```bash
# setup for commands
echo TEAM_NAME="biscuits" >> ~/.bashrc
source ~/.bashrc

helm repo add redhat-cop https://redhat-cop.github.io/helm-charts

helm upgrade --install argocd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  redhat-cop/argocd-operator

oc get pods -w -n ${TEAM_NAME}-ci-cd

# can login and check _nothing is deployed_
# argocd login $(oc get route argocd-server --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd):443 --sso --insecure
# open https://$(oc get route argocd-server --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)

helm upgrade --install .
```

