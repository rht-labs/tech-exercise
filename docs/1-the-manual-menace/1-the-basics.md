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

