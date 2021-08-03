## DO500 Quick Starts for OpenShift - 💥💥 EXPERIMENTAL 💥💥

As a cluster-admin load the getting started files into your cluster
```bash
oc apply -k .
```

The quick start is now available under the *? -> Quick Starts* menu:

We install the **Web Terminal** Operator from RedHat at cluster scope
- https://github.com/redhat-developer/web-terminal-operator

## Operator Config

These 

```bash
# set timeout to 8h (15m default)
oc patch configmap devworkspace-controller -n openshift-operators --patch "
data:
  devworkspace.idle_timeout: 8h
"
```

```bash
oc patch configmap devworkspace-controller -n openshift-operators --patch "
data:
  devworkspace.default_dockerimage.redhat-developer.web-terminal: |
      name: dev
      image: quay.io/eformat/stack-do500:latest
      memoryLimit: 512Mi
      args: ["sleep", "infinity"]
      env:
      - name: DEVWORKSPACE_IDLE_TIMEOUT
        value: 1hr
"
```
