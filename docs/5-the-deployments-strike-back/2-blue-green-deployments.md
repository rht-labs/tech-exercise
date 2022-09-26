## Blue/Green Deployments

> Blue/Green deployments involve running two versions of an application at the same time and moving the traffic from the old version to the new version. Blue/Green deployments make switching between two different versions very easy.

<span style="color:blue;">[OpenShift Docs](https://docs.openshift.com/container-platform/4.9/applications/deployments/route-based-deployment-strategies.html#deployments-blue-green_route-based-deployment-strategies)</span> is pretty good at showing an example of how to do a manual Blue/Green deployment. But in the real world you'll want to automate this switching of the active routes based on some test or other metric. Plus this is GitOps! So how do we do a Blue/Green with all of this automation and new tech, let's take a look with our Nordmart review UI!

![blue-green-diagram](images/blue-green-diagram.png)

1. Let's create two new deployments in our ArgoCD Repo for the `nordmart-review` front end. We'll call one Blue and the other Green. Add 3 new ArgoCD applications in `<tenant-name>/00-argocd-apps/01-dev/`. Adjust the `project` and `source.path` to match what you have built.

    a. `stakater-nordmart-review-ui-bg-blue.yaml`

    ```yaml
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: gabbar-dev-stakater-nordmart-review-ui-bg-blue
        namespace: openshift-gitops
        labels:
          stakater.com/tenant: gabbar
          stakater.com/env: dev
          stakater.com/kind: dev            
      spec:
        destination:
          namespace: gabbar-dev
          server: 'https://kubernetes.default.svc'
        project: gabbar
        source:
          path: 01-gabbar/03-stakater-nordmart-review-ui-bg-blue/01-dev
          repoURL: 'https://github.com/stakater/nordmart-apps-gitops-config.git'
          targetRevision: HEAD
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
    ```

    b. `stakater-nordmart-review-ui-bg-green.yaml`

    ```yaml
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: gabbar-dev-stakater-nordmart-review-ui-bg-green
        namespace: openshift-gitops
        labels:
          stakater.com/tenant: gabbar
          stakater.com/env: dev
          stakater.com/kind: dev            
      spec:
        destination:
          namespace: gabbar-dev
          server: 'https://kubernetes.default.svc'
        project: gabbar
        source:
          path: 01-gabbar/03-stakater-nordmart-review-ui-bg-green/01-dev
          repoURL: 'https://github.com/stakater/nordmart-apps-gitops-config.git'
          targetRevision: HEAD
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
    ```

    c. `stakater-nordmart-review-ui-bg-route.yaml`

    ```yaml
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: gabbar-dev-stakater-nordmart-review-ui-bg-route
        namespace: openshift-gitops
        labels:
          stakater.com/tenant: gabbar
          stakater.com/env: dev
          stakater.com/kind: dev            
      spec:
        destination:
          namespace: gabbar-dev
          server: 'https://kubernetes.default.svc'
        project: gabbar
        source:
          path: 01-gabbar/03-stakater-nordmart-review-ui-bg-route/01-dev
          repoURL: 'https://github.com/stakater/nordmart-apps-gitops-config.git'
          targetRevision: HEAD
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
    ```

    and then create 3 charts, which will be used by above applications

    a. chart and values.yaml file for blue deployment
    
    `03-stakater-nordmart-review-ui-bg-blue\01-dev\Chart.yaml`

    ```yaml
      apiVersion: v2
      name: review-web-blue
      description: A Helm chart for Kubernetes
      dependencies:
      - name: stakater-nordmart-review-ui
        version: 1.0.14
        repository: https://nexus-helm-stakater-nexus.apps.devtest.vxdqgl7u.kubeapp.cloud/repository/helm-charts/
      version: 1.0.14
    ```

    `03-stakater-nordmart-review-ui-bg-blue\01-dev\values.yaml`

    ```yaml
      stakater-nordmart-review-ui:
        application:
          applicationName: "review-ui-blue"
          deployment:
            imagePullSecrets: []
            image:
              repository: stakater/stakater-nordmart-review-ui
              tag: 1.0.15-blue
          service:
            additionalLabels:
              blue_green: active
          route:
            enabled: false
    ```

    b. chart and values.yaml file for green deployment
    
    `03-stakater-nordmart-review-ui-bg-green\01-dev\Chart.yaml`

    ```yaml
      apiVersion: v2
      name: review-web-green
      description: A Helm chart for Kubernetes
      dependencies:
        - name: stakater-nordmart-review-ui
          version: 1.0.14
          repository: https://nexus-helm-stakater-nexus.apps.devtest.vxdqgl7u.kubeapp.cloud/repository/helm-charts/
      version: 1.0.14
    ```

    `03-stakater-nordmart-review-ui-bg-green\01-dev\values.yaml`

    ```yaml
      stakater-nordmart-review-ui:
        application:
          applicationName: "review-ui-green"
          deployment:
            imagePullSecrets: []
            additionalLabels:
              blue_green: inactive
            image:
              repository: stakater/stakater-nordmart-review-ui
              tag: 1.0.15-green
          service:
            additionalLabels:
              blue_green: inactive
          route:
            enabled: false
    ```

    c. route.yaml file for green deployment
    
    `03-stakater-nordmart-review-ui-bg-route\01-dev\route.yaml`

    ```yaml
      kind: Route
      apiVersion: route.openshift.io/v1
      metadata:
        name: review-ui-bg
      spec:
        host: review-ui-bg-<tenant-name>-dev.apps.devtest.vxdqgl7u.kubeapp.cloud
        to:
          kind: Service
          name: review-ui-blue
          weight: 100
        port:
          targetPort: http
        tls:
          termination: edge
          insecureEdgeTerminationPolicy: Redirect
        wildcardPolicy: None
    ```

2. Git commit the changes and in OpenShift UI, you'll see two new deployments are coming alive.

    ```bash
    cd /projects/tech-exercise
    git add --all
    git commit -m  "🍔 ADD - blue & green environments 🍔"
    git push
    ```

3. Verify each of the services contains the correct labels - one should be `active` and the other `inactive`.

    ```bash
    oc get svc -l blue_green=inactive --no-headers -n <TENANT_NAME>-dev
    oc get svc -l blue_green=active --no-headers -n <TENANT_NAME>-dev
    ```

4. With both deployed, let's assume that our blue deployment is the active one with the service having `active` label pointing towards blue deployment and service having `inactive` label pointing towards green deployment. 

We can validate that blue service is currently running by getting the host of our route

```bash
oc get route/review-ui-bg -n (TENANT_NAME)-dev --template='{{.spec.host}}'
```
and then using this URL in browser: `https://(ROUTE_HOST)/#/reviews`


![Nordmart-review-bg-blue](images/nordmart-review-bg-blue.png)


5. let's update the values.yaml for our deployments and switch the labels for services to point the active service towards green deployment. And then update the route to point towards active green service as well. 

    To do this, change the following

    a. Change the service label to `inactive` in blue service `03-stakater-nordmart-review-ui-bg-blue\01-dev\values.yaml`

    b. Change the service label to `active` in green service `03-stakater-nordmart-review-ui-bg-green\01-dev\values.yaml`

    c. Change the `name` of service in `03-stakater-nordmart-review-ui-bg-route\01-dev\route.yaml` route to `review-ui-green`

6. Commit all these changes:

    ```bash
    cd /projects/tech-exercise
    git add .
    git commit -m "🔵 Update - Blue / Green deployment 🟩"
    git push
    ```

8. When ArgoCD syncs, you should see things progress and the blue green deployment happen automatically. You can go to this URL again in browser: `https://(ROUTE_HOST)/#/reviews` and see the green deployment working

![Nordmart-review-bg-blue](images/nordmart-review-bg-green.png)

    This is a simple example to show how we can automate a blue green deployment using GitOps. However, we did not remove the
    previous deployment of `nordmart-review`, in the real world we would do this.
