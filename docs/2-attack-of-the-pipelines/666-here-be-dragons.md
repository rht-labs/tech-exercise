# Here be dragons!

![oh-look-another-dragon](../images/oh-look-dragons.png)

## Tekton Pruning

We can globally configure pruning for Tekton resources by configuring the Operator *TektonConfig*. For example we can keep the last 15 *PipelineRun* resources, and prune every 15 minutes using this configuration:

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

This generates a kubernetes *CronJob* in the *targetNamespace* which is:

```bash
oc get cronjob resource-pruner -n openshift-pipelines -o yaml
```

?> **GitOps** this should be put into the global chart/configuration used to deploy Tekton for the cluster.
