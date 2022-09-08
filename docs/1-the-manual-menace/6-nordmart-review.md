## Deploy Nordmart Review and Nordmart Review UI

### Architecture

Nordmart Review product is composed of three components:

1. **stakater-nordmart-review:** A spring boot based REST API
2. **stakater-nordmart-review-ui:** A react based frontend to managing reviews
3. **mongodb:** A database to hold reviews

![stakater-nordmart-review-architecture](images/stakater-nordmart-review-architecture.jpg)

### Lets get started 

We will first setup the stakater-nordmart-review repository and deploy it on our cluster via helm chart.

## Stakater-Nordmart-Review
1. Clone the stakater-nordmart-review repository that you imported from github to your gitlab account.

        # git clone https://<GITLAB_SERVER>/<YOUR_GITLAB_GROUP>/<YOUR_REPO_NAME>
        git clone https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/workshop-exercise/stakater-nordmart-review

        # cd <YOUR_REPO_NAME>
        cd stakater-nordmart-review

2. Open values.yaml file in the editor and change the **application.deployment.image.repository** and **application.deployment.image.tag** keys in yaml
    > **NOTE:**  We have already built an image for the application and pushed it to nexus image repository.  

    repository: <NEXUS_URL>/stakater-nordmart-review
    tag: latest

    <p align="center" width="100%">
    <img width="100%" src="images/1-6-1-change-image-tag.jpg">
    </p>

3. Lets use helm to install our stkater-nordmart-review application to the cluster. Run following command in stakater-nordmart-review directory.

        helm install <TENANT_NAME> deploy/ -n <TENANT_NAME>-test --dependency-update

    > **NOTE**: Make sure you are logged into the openshift cluster via cli.

    > Thanks to **tenant operator** this **<TENANT_NAME>-test** project is already available to us in the cluster where we can deploy this application

4. Login to Openshift UI, Select your project  **<TENANT_NAME>-test** and Navigate to Pods under Workloads in left side bar. 

    <p align="center" width="100%">
    <img width="%" src="images/1-6-2-oc-pods-ui">
    </p>

5. You will see a pod named review-web / <application_name> created. Helm also created the following supporting resources.

 - ServiceAccount
 - ConfigMap
 - PersistentVolumeClaim
 - Service
 - Deployment
 - AlertmanagerConfig
 - EndpointMonitor
 - GrafanaDashboard
 - PrometheusRule
 - Route
 - Service
 - SealedSecret
 - ServiceMonitor


6. Navigate to Routes under Network in left side bar. Our application is available via this endpoint. 

    <p align="center" width="100%">
    <img width="%" src="images/1-6-3-oc-route-ui">
    </p>

    Lets send a curl request to this endpoint and see the response.
        
        # Get Review
        curl <ROUTE_LOCATION>:8080/api/review/329199

        # Add a Review with Username: bumblebee, ProductId: 329199, Review Rating: 5 and Comment: great
        curl -X POST '<ROUTE_LOCATION>:8080/api/review/329199/bumblebee/5/great'
        