# Here be dragons!

![oh-look-another-dragon](../images/oh-look-dragons.png)

## Tekton Pruning

We can globally configure pruning for Tekton resources by configuring the Operator *TektonConfig*. For example, we can keep the last 15 *PipelineRun* resources, and prune every 15 minutes using this configuration:

```yaml
  pruner:
    keep: 15
    resources:
      - pipelinerun
    schedule: '*/15 * * * *'
```

As a **cluster-admin** patch this in using:

```bash
oc patch tektonconfig config -p '{"spec":{"pruner":{"keep":15,"resources":["pipelinerun"],"schedule":"*/15 * * * *"}}}' --type=merge
```

This generates a Kubernetes *CronJob* in the *targetNamespace* which is:

```bash
oc get cronjob resource-pruner -n openshift-pipelines -o yaml
```

?> **GitOps** this should be put into the global chart/configuration used to deploy Tekton for the cluster.

## Tekton Affinity Assistant Configuration

From Red Hat OpenShift 1.19.0 there is a change to disable the affinity assistant which it could impact in the first
execution of the Maven pipelines:

```text
[User error] more than one PersistentVolumeClaim is bound
```

If your pipelines are facing that error, the solution is already described in a [Knowledge Base Article](https://access.redhat.com/solutions/7128120).
That solution requires to make a change in the `TektonConfig` object to apply the `disabled` value to the `pipeline.coschedule` parameter:

```bash
oc patch tektonconfig config -p '{"spec":{"pipeline":{"params":[{"name":"coschedule","value":"disabled"}]}}}' --type=merge
```

> This change must be done by a `cluster-admin` user.
