
### Stack Rox
> what is it why important


#### Group Exercise

StackRox / Advanced Cluster Security (ACS) is deployed once at the cluster scope. It can be used to monitor multiple clusters. As `cluster-admin` perform the setup of Stackrox as a class together. These step(s) may have been done for you, ask your instructor.

1. Create a project called `stackrox` in your cluster

2. Install the `Advanced Cluster Security` Operator at cluster scope
![images/acs-operator.png](images/acs-operator.png)

`FIXME` - gitopsify this
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhacs-operator
  namespace: openshift-operators
spec:
  channel: latest
  installPlanApproval: Automatic
  name: rhacs-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: rhacs-operator.v3.63.0
```

3. Create a `Central` configuration.

`FIXME` - gitopsify this
```yaml
apiVersion: platform.stackrox.io/v1alpha1
kind: Central
metadata:
  namespace: openshift-operators
  name: stackrox-central-services
spec:
  central:
    exposure:
      loadBalancer:
        enabled: false
        port: 443
      nodePort:
        enabled: false
      route:
        enabled: true
    persistence:
      persistentVolumeClaim:
        claimName: stackrox-db
  egress:
    connectivityPolicy: Online
  scanner:
    analyzer:
      scaling:
        autoScaling: Enabled
        maxReplicas: 5
        minReplicas: 2
        replicas: 3
    scannerComponent: Enabled
```

4. Once deployed you can connect to the ACS WebUI Route using the `admin` credentials
```bash
oc -n stackrox get secret central-htpasswd -o go-template='{{index .data "password" | base64decode}}'
```

5. Create an `API Token` Integration to use in our automations from the ACS WebUI -> Integration page

![images/acs-api-token.png](images/acs-api-token2.png)
![images/acs-api-token.png](images/acs-api-token.png)

6. Save the token, we will need of later on. Export these environment variables:
```bash
export ROX_API_TOKEN=eyJhbGciOiJSUzI1NiIsIm...
export ROX_ENDPOINT=central-stackrox.<CLUSTER_DOMAIN>
```

6. Download the `roxctl` client for your local machine. You can aslo download directly from ACS WebUI
```bash
curl -O https://mirror.openshift.com/pub/rhacs/assets/3.63.0/bin/Linux/roxctl && chmod 755 ./roxctl
```

7. Test that `roxctl` works by running
```bash
./roxctl central whoami --insecure-skip-tls-verify -e $ROX_ENDPOINT:443
```

8. Generate the init bundle to connect the current cluster (or any other cluster!) to ACS. This can be done from the ACS WebUI or by downloading the Kubernetes secrets file and applying
- https://docs.openshift.com/acs/installing/install-ocp-operator.html#generate-init-bundle
```bash
oc -n stackrox create -f sandbox1350-cluster-init-secrets.yaml
```
![images/acs-generate-bundle-init.png](images/acs-generate-bundle-init.png)

9. Create a `Secured Cluster` object in the ACS Operator. You can use the internal ServiceName for the same cluster:
```yaml
  centralEndpoint: 'central.stackrox:443'
  clusterName: sandbox1350
```
![images/acs-secured-cluster.png](images/acs-secured-cluster.png)

10. You should now be able to see your cluster and all the data in ACS for you cluster. Take a look around.

![images/acs-cluster-import.png](images/acs-cluster-import.png)
![images/acs-compliance-graphs.png](images/acs-compliance-graphs.png)

11. `FIXME` to make roxctl cli work on internal images i needed to manually add a registry. There is autmatically discovered registries there so it should be automatic using the ServiceAccount ?
```bash
# Platform Configurations -> Generic Docker Registry
# add image-registry.openshift-image-registry.svc:5000 -> $(oc whoami --show-token)
```

#### Task per group

Now we can use ACS to help move security `LEFT` in our build pipeline. In each group we will:

🐈‍⬛ `Jenkins Group` 🐈‍⬛
- [ ] Configure a StackRox kubelinter - to check resources prior to packaging with [helm](https://hub.tekton.dev/tekton/task/kube-linter)
- [ ] Configure a `Lifecycle Stage:Build` policy in [ACS](https://docs.openshift.com/acs/integration/integrate-with-ci-systems.html#integrate-ci-check-existing-build-phase-policies_integrate-with-ci-systems)
- [ ] Configure you pipeline to `check and scan` images
- [ ] Configure you pipeline to report any `Policy` failures
- [6a-jenkins.md](6a-jenkins.md)

🐅 `Tekton Group` 🐅
- [ ] Configure a StackRox kubelinter - to check resources prior to packaging with [helm](https://hub.tekton.dev/tekton/task/kube-linter)
- [ ] Configure a `Lifecycle Stage:Build` policy in [ACS](https://docs.openshift.com/acs/integration/integrate-with-ci-systems.html#integrate-ci-check-existing-build-phase-policies_integrate-with-ci-systems)
- [ ] Configure you pipeline to `check and scan` images
- [ ] Configure you pipeline to report any `Policy` failures
- [6a-tekton.md](6a-tekton.md)
