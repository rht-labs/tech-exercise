#### User Workload Monitoring
> OpenShift's monitoring capabilities.... 

[link to the docs](https://docs.openshift.com/container-platform/4.8/monitoring/enabling-monitoring-for-user-defined-projects.html)

### OCP Developer view Monitoring (pods etc)
> Out of the box monitoring in OpenShift - this gives us the Kubernetes metrics for our apps such as Memory usage & CPU etc.

1. To enable the User Workload Monitoring, a one line change has to be made to a config map. This is cluster wide so it's already been done for you, but if you're interested how the [docs are here](https://docs.openshift.com/container-platform/4.8/monitoring/enabling-monitoring-for-user-defined-projects.html#enabling-monitoring-for-user-defined-projects_enabling-monitoring-for-user-defined-projects). On the OpenShift UI, go to *Monitoring*, it should show basic health indicators
![petbattle-default-metrics](images/petbattle-default-metrics.png)

2. Run a promql query to get some info
![petbattle-promql](images/petbattle-promql.png)

3. basic basic basic....

### Add Grafana & Service Monitor
> Let's super charge our monitoring with specific JVM and API calls etc...

1. Enable ServiceMonitor in PetBattle apps & show them in PROMQL in OCP?
OpenShift gathers the base metrics to see how our pods are doing. In order to get application specific metrics (like response time or active users etc) alongside the base ones, we need another object: _ServiceMonitor_. ServiceMonitor will let Prometheus know which endpoint the metrics are exposed so that Prometheus can scrape them. And once the Prometheus has the metrics, we can run query on them (just like we did before!) and create shiny dashboards!

**Example** ServiceMonitor object:
<pre>
  ---
  <span style="color:#0077AA;">apiVersion:</span> monitoring.coreos.com/v1
  <span style="color:#0077AA;">kind:</span> ServiceMonitor
  <span style="color:#0077AA;">metadata:</span>
    <span style="color:#0077AA;">name:</span> my-app
  <span style="color:#0077AA;">spec:</span>
    <span style="color:#0077AA;">endpoints:</span>
      <span style="color:#0077AA;">- interval:</span> 30s
        <span style="color:#0077AA;">port:</span> tcp-8080 <span style="color:green;" >#port that metrics are exposed</span>
        <span style="color:#0077AA;">scheme:</span> http
    <span style="color:#0077AA;">selector:</span>
      <span style="color:#0077AA;">matchLabels:</span>
        <span style="color:#0077AA;">app:</span> my-app
</pre>

Now, let's create ServiceMonitor for our PetBattle apps! Of course, we will do it through ArgoCD because this is GITOPS!!
Open up `pet-battle/test/values.yaml` and `pet-battle/staging/values.yaml` files. Update `values` for `pet-battle` and `pet-battle-api` with adding following:
```yaml
    servicemonitor: true
```

Then push it to the git repo.
```bash
git add .
git commit -m "🖥️ ServiceMonitor enabled 🖥️"
git push
```

If you want to verify the objects:
```bash
oc get servicemonitor -n ${TEAM_NAME}-test
```

2. We can create our own application specific dashboards to display live data for ops use or efficiency or A/B test results. We will use Grafana to create dashboards and since it will be another tool, we need to install it through `ubiquitous-journey/values-tooling.yaml`
```yaml
  - name: grafana
    enabled: true
    source: https://github.com/petbattle/pet-battle-infra.git
    source_path: grafana
```
Commit the changers to the repo as you've done before
```bash
git add .
git commit -m "📈 Grafana added 📈"
git push
```

3. Once this change has been sync'd (you can check this in ArgoCD), Let's login to Grafana and view the predefined dashboards for Pet Battle;
```bash
# get the route and open it in your broswer
oc get route grafana-route --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd
```
If you use `Log in with OpenShift` to login and display dashboards - you user will only have `view` role which is read-only. This is alright in most cases, but we want to be able to edit and admin the boards.

5. The Dashboards should be showing some basic information and we can generate more data by firing some requests to the `pet-battle-api`. In your IDE, run on your terminal:
```bash
curl -vL $(oc get route/pet-battle-api -n ${TEAM_NAME}-test --template='{{.spec.host}}')/dogs
curl -vL -X POST -d '{"OK":"🐈"}' $(oc get route/pet-battle-api -n pants-test --template='{{.spec.host}}')/cats/
curl -vL $(oc get route/pet-battle-api -n ${TEAM_NAME}-test --template='{{.spec.host}}')/api/dogs
curl -vL -X POST -d '{"OK":"🦆"}' $(oc get route/pet-battle-api -n pants-test --template='{{.spec.host}}')/cats/
curl -vL $(oc get route/pet-battle-api -n ${TEAM_NAME}-test --template='{{.spec.host}}')/api/dogs
curl -vL -X POST -d '{"OK":"🐶"}' $(oc get route/pet-battle-api -n pants-test --template='{{.spec.host}}')/cats/
```

6. Back in Grafana, we should see some data populated into the `4xx` and `5xx` boards...
![grafana-http-reqs](./images/grafana-http-reqs.png)


### Create a Dashboard
> Dashboards are easily shared as they can be exported as `JSON`. Let's extend the Pet Battle Dashboard with a new `panel`

1. OpenShift users have a read-only view on Grafana by default - get the `admin` user details from your cluster:
```bash
oc get secret grafana-admin-credentials -o=jsonpath='{.data.GF_SECURITY_ADMIN_PASSWORD}' -n ${TEAM_NAME}-ci-cd \
  | base64 -d; echo -n
```

2. Back on Grafana, `login` with these creds after you've signed in using the OpenShift Auth (yes we know this is silly but so are Operators):
![grafana-login-admin](./images/grafana-login-admin.png)


3. Once you've signed in, add a new panel:
![grafana-add-panel](./images/grafana-add-panel.png)

4. On the new panel, let's configure it to query for some information about our projects. We're going to use a very simple query to count the number of pods running in the namespace (feel free to use any other query). On the Pannel settings, set the title to something sensible and add the query below. Hit save!
```bash
sum(kube_pod_status_ready{namespace="<TEAM_NAME>-test",condition="true"})
```
![new-panel](./images/new-panel.png)

5. With the new panel on our dashboad, let's see it in action by killing off some pods in our namespace
```bash
oc delete pods -l app.kubernetes.io/instance=pet-battle-api -n ${TEAM_NAME}-test
oc delete pods -l app.kubernetes.io/instance=pet-battle -n ${TEAM_NAME}-test
```
![grafana-less-pods](./images/grafana-less-pods.png)



^ 🐌 [THIS IS NOT GITOPS - see advanced exercises for creating and storing the dashboard as code] 🐌


