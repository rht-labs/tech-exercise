## 🐌 The Basics - CRW, OCP & Helm

1. Login to your CRW envionemnt [TODO]

2. Setup your team name in the env:
```bash
# setup for commands
echo TEAM_NAME="biscuits" >> ~/.bashrc
```
```bash
# setup for commands
echo CLUSTER_DOMAIN="apps.example.region.rht-labs.com" >> ~/.bashrc
```
```bash
source ~/.bashrc
```

3. Check if you can connect to OpenShift
```bash
# check if you can access the cluster
oc login --server=https://api.example.region.rht-labs.com -u <USERNAME> -p <PASSWORD>
```
```bash
# verify your permissions
oc new-project ${TEAM_NAME}-ci-cd
```

4.  TODO - Familiarise yourself with some basic helm...
    * thinking add some random chart / website / app eg Residency Microsite? 
    * change values eg defaults and then override on the command line
    * show values changed?

