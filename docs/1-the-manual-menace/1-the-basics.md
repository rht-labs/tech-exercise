## 🐌 The Basics - CRW, OCP & Helm

1. Login to your CRW envionemnt `FIXME`

2. Setup your team name in the env:
```bash
# setup for commands
echo export TEAM_NAME="biscuits" | tee -a ~/.bashrc -a ~/.zshrc
```

3. Check if you can connect to OpenShift
```bash
# check if you can access the cluster
oc login --server=https://api.${CLUSTER_DOMAIN} -u <USERNAME> -p <PASSWORD>
```

4. Retrieve the `CLUSTER_DOMAIN` 
```bash
# setup cluster domain
CLUSTER_DOMAIN=$(oc get ingress.config/cluster -o 'jsonpath={.spec.domain}')
echo export CLUSTER_DOMAIN=${CLUSTER_DOMAIN} | tee -a ~/.bashrc -a ~/.zshrc
```

5. Verify the variables you have set
```bash
# verify variables
source ~/.bashrc
echo ${CLUSTER_DOMAIN}
echo ${TEAM_NAME}
```

6. Check your user permissions in OpenShift by creating your team CICD project
```bash
# verify your can create a project
oc new-project ${TEAM_NAME}-ci-cd
```
### TODO - Familiarise yourself with some basic helm...
    * thinking add some random chart / website / app eg Residency Microsite? 
    * change values eg defaults and then override on the command line
    * show values changed?
