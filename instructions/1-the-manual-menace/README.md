
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


```
# Assumption - Sealed Secrets is deployed ... values I used were 
oc new-project shared-do500
helm upgrade --install ss -f ss-values.yaml sealed-secrets/sealed-secrets --force

nameOverride: sealed-secrets
fullnameOverride: sealed-secrets
# namespace must exist, so we use labs-ci-cd by default.
namespace: shared-do500
# Dont touch the security context values, deployment will fail in OpenShift otherwise.
securityContext:
  runAsUser: ""
  fsGroup: ""
commandArgs:
  - "--update-status=true"

[ss-guide](https://github.com/petbattle/ubiquitous-journey/blob/main/docs/sealed-secrets.md)

TODO - decide how we can enable catch-up easily.... if we use a less strict scope we could reuse the Cert that SS is encryting things with and so the act of sealing would generate same values each time.




```
