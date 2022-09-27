## Autoscaling

> Horizontal pod autoscaler (HPA) helps us to specify how OpenShift should automatically increase or decrease the number of pod replicas of an application, based on metrics collected from the pods. When we define an HPA (based on CPU and/or memory usage metrics), the platform calculates the current usage and compare it with the utilization threshold and scales pods up or down accordingly.

1. The `stakater-nordmart-review` uses stakater's [application chart](https://github.com/stakater-charts/application/tree/master/application) as a dependency. This chart already contains a template for Horizontal Pod Autoscaler.
   By default, the horizontal pod autoscaler is disabled in our `stakater-nordmart-review` chart.

> Often we only enable the HPA in the stage or prod environments, so being able to configure it on / off when testing is useful. To turn it on in a given environment, we can simply supply new values to our application config. Now let's do it for `stakater-nordmart-review`

2. Head over to your `stakater-nordmart-review` repository and navigate to `deploy > values.yaml`. Click `Edit in Web IDE`.

   ![hap-edit](./images/hpa-edit.png)

3. Under the `application:`, add the following yaml block. It should have the same indent as `applicationName: review`

    ```yaml
      autoscaling:
        enabled: true
        minReplicas: 1
        maxReplicas: 5
        metrics:
        - type: Resource
          resource:
            name: cpu
            target: 
              type: Utilization
              averageUtilization: 60
    ```
   ![hpa-edit](./images/hpa-edit2.png)

4. Git commit the changes.


5. With the change synchronized, we should see a new HorizontalPodAutoscaler object in ArgoCD and the cluster.
   Let's check this by going to ArgoCD and opening up application `<TENANT_NAME>-dev-stakater-nordmart-review`

   You will be able to see HPA deployed once the pipeline that we have deployed in section 3 succeeds!! If it isn't, refresh the application.
   ![hpa-argocd.png](./images/hpa-argocd.png)


6. Let's now test our pod autoscaler, to do this we want to fire lots of load on the API of review microservice. This should trigger an autoscaling event due to the increased load on the pods. [hey](https://github.com/rakyll/hey) is simple load testing tool that can be run from the command line that will fire lots of load at our endpoint:

   Run the following command in your **CRW**.

    ```bash
    hey -t 30 -c 10 -n 10000 -H "Content-Type: application/json" -m GET https://$(oc get route/review -n <TENANT_NAME>-dev --template='{{.spec.host}}')/api/review/329199
    ```

   Where:
   * -c: Number of workers to run concurrently (10)
   * -n: Number of requests to run (10,000)
   * -t: Timeout for each request in seconds (30)

7. While this is running, we should see in OpenShift land the autoscaler is kicking in and spinning up additional pods.  Open the `Workloads` tab. At the very bottom you will see HorizontalPodAutoScalar. Click instances and open the review HPA. You will see the below screen
    Notice the cpu utilization and desired replica count. It has jumped!

   ![scale-up](./images/scale-up.png)

8. If you navigate to the review deployment, you should see the replica count has jumped and so have the number of pods.

   ![hpa-deployment.png](./images/hpa-deployment.png)

   ![replicas-hpa](./images/replicas-hpa.png)


9. Now let's wait for a couple of minutes for load to ease. Navigate back to the `review` HorizontalPodAutoscaler. You will see that the CPU utilization and desired replicas have started going down.


   ![scale-down](./images/scale-down.png)

10. Go to the review deployment, you will see that it has brought the pods down (Or is trying to decrease the number of pods)

  ![scale-down](./images/scale-down2.png)


   WELLDONE!! YOU NOW HAVE AUTO SCALING WITH YOUR APPLICATION!!

