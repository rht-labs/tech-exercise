## User Workload Monitoring

> SAAP (Stakater App Agility Platform) has monitoring capabilities built in. It deploys the prometheus stack and integrates into the OpenShift UI for consuming cluster metrics.

### SAAP Developer view Monitoring (pods etc.)

> Out of the box monitoring in SAAP gives us the Kubernetes metrics for our apps such as Memory, CPU, Storage, etc.

1. User Workload Monitoring is enabled by default in SAAP.

    On the SAAP UI, go to *Observe*, it should show basic health indicators

    ![product-review-default-metrics](images/product-review-default-metrics.png)

2. You can run queries across the namesapce easily with `promql`, a query language for Prometheus. Run a `promql` query to get some info about the memory consumed by the pods in your `dev` namespace

    ```bash
    sum(container_memory_working_set_bytes{container!='',namespace='<TENANT_NAME>-dev'}) by (pod)
    ```

    ![product-review-promql](images/product-review-promql.png)

### Add Grafana & Service Monitor

> Let's super charge our monitoring with specific information about our cat based services ...

1. Lets Enable ServiceMonitor in ProductReview apps.

    SAAP gathers the base metrics to see how our pods are doing. In order to get application specific metrics (like response time or number of reviews or active users etc) alongside the base ones, we need another object: _ServiceMonitor_. ServiceMonitor will let Prometheus know which endpoint the metrics are exposed so that Prometheus can scrape them. And once the Prometheus has the metrics, we can run query on them (just like we did before!) and create shiny dashboards!

    **Example** ServiceMonitor object:

    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
    ---
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      labels:
         app: review
      name: review-svc-monitor
      namespace: (TENANT_NAME)-dev
    spec:
      endpoints:
        - interval: 5s
          port: http # port that metrics are exposed
          path: /actuator/prometheus
      namespaceSelector:
       matchNames:
       - (TENANT_NAME)-dev
      selector:
        matchLabels:
          app: review
    </code></pre></div>

    Now, let's create add the `ServiceMonitor` for our ProductReview apps! Of course, we will do it through Helm and ArgoCD because this is GITOPS!!

    Our Helm Chart for nordmart-review api Open up `stakater-nordmart-review/deploy/values.yaml` file. Update `values` for `review` with adding following:

    ```yaml
        ## Service Monitor
        serviceMonitor:
            enabled: true    
    ```

    Then push it to the git repo.

    ```bash
    cd /projects/tech-exercise
    git add .
    git commit -m "🖥️ ServiceMonitor enabled 🖥️"
    git push
    ```

    If you want to verify the object exists you can run from your terminal:

    ```bash
    oc get servicemonitor -n ${TENANT_NAME}-dev -o yaml
    ```

   This is how the serviceMonitor will look like in openshift cluster

   ![sevice-monitor](./images/review-service-monitor.png)


2. We can create our own application specific dashboards to display live data for ops use or efficiency or A/B test results. We will use Grafana to create dashboards. SAAP monitoring stack includes grafana installation. Add an existing dashboard to norwdmart-review api; the dashboard can be found `nordmart-review/deploy/templates/grafana-dashboard.yaml` folder.

    ```yaml
        # Grafana Dashboard
        grafanaDashboard:
            enabled: true
    ```

3. Commit the changes to the repo as you've done before

    ```bash
    cd /projects/tech-exercise
    git add .
    git commit -m "📈 Grafana dashboard enabled 📈"
    git push
    ```

4. Once this change has been sync'd (you can check this in ArgoCD), Let's login to Grafana and view the predefined dashboards for nordmart review api;

    ![forecastle-workload-grafana](images/forecastle-workload-grafana.png)

    If you use `Log in with OpenShift` to login and display dashboards - you user will only have `view` role which is read-only. This is alright in most cases, but we want to be able to edit and admin the boards.

5. The Dashboards should be showing some basic information and we can generate more data by firing some requests to the `nordmart-review` api. In your IDE, run on your terminal:

    ```bash
    # Get the reviews for a specific Product (i.e. 329199)
    curl -L $(oc get route/review ${TENANT_NAME}-dev --template='{{.spec.host}}')/api/review/329199
    # Add a review for a specific Product (i.e. 329199)
    curl -L -X POST $(oc get route/review -n ${TENANT_NAME}-dev --template='{{.spec.host}}')/api/review/329199/John/5/Great
    # Delete a review for a specific review (First get the review id from Get request)
    curl -L -X DELETE $(oc get route/review -n ${TENANT_NAME}-dev --template='{{.spec.host}}')/api/review/6323904100aeb66032db19dc
    ```

6. Back in Grafana, we should see some data populated into the boards... Go to the Manage and then click on your <TENANT_NAME>-dev.

    ![grafana-http-reqs](./images/product-review-grafana-dashboard-manage.png)
    ![grafana-http-reqs](./images/product-review-grafana-dashboard-tanent.png)
    ![grafana-http-reqs](./images/product-review-grafana-dashboard.png)

### Create a Dashboard

> Let's extend the Nordmart Review Dashboard with a new `panel` to capture some metrics in a visual way for us. Configuring dashboards is easy through the Grafana UI. Then Dashboards are easily shared as they can be exported as a `JSON` document.

1. Login back on Grafana

2. Once you've signed in, add a new panel:

    ![grafana-add-panel](./images/grafana-add-panel.png)

3. On the new panel, let's configure it to query for some information about our projects. We're going to use a very simple query to count the number of pods running in the namespace (feel free to use any other query). On the Panel settings, set the title to something sensible and add the query below. Hit save!

    ```bash
    sum(kube_pod_status_ready{namespace="<TENANT_NAME>-dev",condition="true"})
    ```

    ![new-panel](./images/new-panel.png)

4. With the new panel on our dashboard, let's see it in action by killing off some pods in our namespace

    ```bash
    oc delete pods -l app=review -n ${TENANT_NAME}-dev
    oc delete pods -l app=review-web -n ${TENANT_NAME}-dev
    ```

    ![grafana-less-pods](./images/grafana-less-pods.png)

    <p class="tip">
    🐌 THIS IS NOT GITOPS - Manually configuring the dashboard is a good way to play with Grafana. See advanced exercises for creating and storing the dashboard as code 🐎
    </p>
