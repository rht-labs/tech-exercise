
## Here be dragons!

![oh-look-another-dragon](../images/oh-look-dragons.png)

Wanna know how to do more advanced stuff? Argo provides a lot of features that we can use to our advantage.

### Argo Rollouts

Argo Rollouts extends OpenShift's standard Deployment capabilities, enabling advanced deployment strategies like A/B testing, canary releases, and blue/green deployments directly within your OpenShift GitOps workflows.

**How it works:**
- Argo Rollouts replaces the standard `Deployment` resource with a custom `Rollout` resource
- Provides fine-grained control over traffic splitting between different versions using OpenShift Routes
- Integrates seamlessly with OpenShift Service Mesh (based on Istio) for advanced traffic management
- Includes built-in analysis capabilities to automatically promote or rollback based on metrics from OpenShift monitoring

**Configuration in OpenShift GitOps:**
- Install the OpenShift GitOps Operator from OperatorHub in your OpenShift cluster and configure it to use Argo Rollouts
- Define `Rollout` resources in your Git repository managed by OpenShift GitOps
- Configure traffic splitting using OpenShift Routes and Service Mesh VirtualServices
- The OpenShift GitOps Operator (Argo CD) will automatically sync and manage Rollout resources
- Leverage OpenShift's built-in Prometheus metrics for analysis-based rollouts

**Learn more:**
- [Argo Rollouts Documentation](https://argoproj.github.io/rollouts/)
- [OpenShift GitOps Operator](https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/1.18/html/understanding_openshift_gitops)
- [OpenShift Service Mesh](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/service_mesh/service-mesh-2-x)


### Vertical Pod Autoscaler

Vertical Pod Autoscaler (VPA) is a Kubernetes tool that automatically adjusts the CPU and memory resources allocated to pods based on their observed resource usage patterns. It helps optimize resource utilization by scaling containers up or down as needed, ensuring efficient use of available resources.

**How it works:**
- VPA monitors resource usage of each pod and adjusts the resource requests and limits accordingly
- It can automatically scale up or down the number of replicas based on observed CPU and memory usage
- It can also automatically scale the resources allocated to each pod based on observed usage patterns

**Learn more:**
- [Kubernetes Vertical Pod Autoscaler Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/)
- [OpenShift Vertical Pod Autoscaler Documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/nodes/working-with-pods#nodes-pods-vpa)
