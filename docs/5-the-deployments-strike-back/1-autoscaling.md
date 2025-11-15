## Autoscaling

In this exercise, we'll configure and test the Horizontal Pod Autoscaler (HPA) for the Pet Battle API application. HPA automatically adjusts the number of pod replicas based on observed CPU and memory utilization, ensuring your application can handle varying loads efficiently.

### Understanding Horizontal Pod Autoscaler

> **Horizontal Pod Autoscaler (HPA)** helps us specify how OpenShift should automatically increase or decrease the scale of an application, based on metrics collected from the pods. After we define an HPA (based on CPU and/or memory usage metrics), the platform calculates the current usage and compares it with the desired utilization, then scales pods up or down accordingly.

HPA monitors your application's resource consumption and automatically:
- **Scales up** when CPU or memory usage exceeds the target thresholds
- **Scales down** when resource usage drops below the thresholds
- Maintains the number of replicas between the configured minimum and maximum values

This ensures your application has enough resources during peak loads while avoiding unnecessary resource consumption during low-traffic periods.

---

## Implementing Autoscaling

We'll enable HPA for the Pet Battle API and test it by generating load to observe the automatic scaling behavior.

### Phase 1: Review the HPA Configuration

**Step 1: Examine the HPA Template**

The Pet Battle API Helm chart contains the Horizontal Pod Autoscaler YAML. By default, we've switched it off. This is what it looks like:

```yaml
# Source: pet-battle-api/templates/hpa.yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pet-battle-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: pet-battle-api
  minReplicas: 2
  maxReplicas: 6
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: AverageValue
          averageValue: 200m
    - type: Resource
      resource:
        name: memory
        target:
          type: AverageValue
          averageValue: 300Mi
```

This configuration:
- Maintains a minimum of 2 replicas
- Can scale up to a maximum of 6 replicas
- Scales based on CPU usage (target: 200 millicores average)
- Scales based on memory usage (target: 300Mi average)

### Phase 2: Enable HPA

**Step 2: Configure HPA in Values**

Often we only enable the HPA in staging or production environments, so being able to configure it on/off when testing is useful. To turn it on in a given environment, we can simply supply new values to our application config.

Update the `tech-exercise/pet-battle/test/values.yaml` by setting the `hpa` to `enabled: true`:

```yaml
  # Pet Battle API
  pet-battle-api:
    name: pet-battle-api
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle-api
    source_ref: 1.5.0
    values:
      image_name: pet-battle-api
      image_version: 1.0.0
      # ✋ ✋ ADD THIS CONFIG BELOW TO YOUR values.yaml FILE 
      hpa:
        enabled: true
        cpuTarget: 200m
        memTarget: 300Mi
```

> **Note**: The `cpuTarget` and `memTarget` values define the average resource usage thresholds that trigger scaling. When the average CPU or memory usage across all pods exceeds these values, HPA will scale up. When usage drops below these thresholds, HPA will scale down.

**Step 3: Deploy the Configuration**

Commit the changes to trigger Argo CD to deploy the HPA configuration. We probably don't need to tell you the commands to do this by now, but just in case... here they are again 🐎🐎🐎!

```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m "🐎ADD - HPA enabled for test env 🐎 "
git push
```

**Step 4: Verify HPA Creation**

With the change synchronized, we should see a new object in Argo CD and the cluster. Feel free to check those out:

- In Argo CD UI: Look for the HPA resource in the pet-battle-api application
- In OpenShift UI: Navigate to the pet-battle-api deployment and check for the HPA resource
- Via command line: `oc get hpa -n ${TEAM_NAME}-test`

### Phase 3: Test the Autoscaler

**Step 5: Create a Load Test Script**

Let's now test our pod autoscaler. To do this, we want to fire lots of load on the API of pet-battle. This should trigger an autoscale due to the increased load on the pods. `k6` is a simple load testing tool that can be run from the command line that will fire lots of load at our endpoint.

First, create the `load.js` JavaScript file that defines the load test type to run:

```javascript
cat << EOF > /tmp/load.js
import http from 'k6/http';
import { sleep } from 'k6';
export default function () {
  http.get('https://$(oc get route/pet-battle-api -n ${TEAM_NAME}-test --template='{{.spec.host}}')/cats');
}
EOF
```

This script will continuously make HTTP GET requests to the `/cats` endpoint, generating load on the API.

**Step 6: Run the Load Test**

Then, using the `k6` binary, run the load test using more than one virtual user and a defined duration:

```bash
k6 run --insecure-skip-tls-verify --vus 100 --duration 300s /tmp/load.js 
```

Where:
- `--vus`: Number of virtual users (VUs) to run concurrently (100)
- `--duration`: Test duration limit (300s = 5 minutes)
- `--insecure-skip-tls-verify`: Skip TLS certificate verification (needed for self-signed certificates)

> **Tip**: This will generate significant load on your API. The 100 virtual users making continuous requests should cause CPU and memory usage to spike, triggering the HPA to scale up.

**Step 7: Observe the Autoscaling**

While this is running, we should see in OpenShift that the autoscaler is kicking in and spinning up additional pods. If you navigate to the pet-battle-api deployment, you should see the replica count has jumped.

![petbattle-api-hpa](./images/petbattle-api-hpa.png)
![petbattle-api-hpa-topology](./images/petbattle-api-hpa-topology.png)
![petbattle-api-deployment](./images/petbattle-api-deployment.png)

> **What to watch for**:
> - The number of pod replicas should increase from the minimum (2) toward the maximum (6)
> - CPU and memory metrics should show increased usage
> - The HPA status should show current and desired replica counts

**Step 8: Observe Scale-Down**

After a few moments (once the load test completes and traffic returns to normal), you should see the autoscaler settle back down and the replicas are reduced.

![petbattle-api-scale-down](./images/petbattle-api-scale-down.png)

The HPA will gradually scale down the replicas as resource usage decreases, eventually returning to the minimum number of replicas (2) when the load subsides.


> HPA is a powerful feature that helps ensure your applications can handle varying loads efficiently without manual intervention. By setting appropriate minimum and maximum replica counts and resource thresholds, you can ensure your applications have the resources they need when demand is high, while avoiding unnecessary resource consumption during low-traffic periods.
