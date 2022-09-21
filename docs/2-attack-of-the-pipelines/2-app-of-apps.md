## Deploy App of Apps

We need a way to bundle up all of our applications and deploy them into each environment. The nordmart application has its own Git repository and Helm chart, making it easier to code and deploy independently from other apps.

A developer can get the same experience and end result installing an application chart using `helm install` as our fully automated pipeline. This is important from a useability perspective. Argo CD has great support for all sorts of packaging formats that suit Kubernetes deployments, `Kustomize`, `Helm`, as well as just raw YAML files. Because Helm is a template language, we can mutate the Helm chart templates and their generated Kubernetes objects with various values allowing us to configure them with configuration per environment.

We deploy each of our applications using an Argo CD `application` definition. We use one Argo CD `application` definition for every environment in which we wish to deploy the application. We make use of Argo CD `app of apps pattern` to bundle all of these all up; some might call this an application suite or a system! In nordmart we generate the app-of-apps definitions using a Helm chart.

### Deploying Pet Battle - Keycloak

> In this exercise we'll deploy nordmart-review. We'll deploy nordmart to dev environment. And then get the build environment ready for deploying our pipelines

1. Head over to the below url.

   `https://github.com/stakater-lab/nordmart-apps-gitops-config-template`
    
This is the template that we will use to create our own apps-of-apps repository.
 

2. Copy the clone url.

   `https://github.com/stakater-lab/nordmart-apps-gitops-config-template.git`
 

3. Now open gitlab and select create project. In the screen that appears, choose `Import project`.

   ![clone-apps-config](images/clone-apps-config.png)


4. Select import repository from url and paste in the url that you copied in step 2. 

   Note: Make the repository public. Add `nordmart-apps-gitops-config` and `Nordmart Apps Gitops Config` as the repository name. Also make sure that you use the correct group name.

   ![import-gitops-apps](images/import-gitops-apps.png)

5. Once the repository is import. Clone the repository. 

6. cd into the repository. Now in the terminal type:

   curl https://raw.githubusercontent.com/stakater/workshop-excercise/main/scripts/update-nordmart-apps-with-tenant-info.py > script.py

This will download a python script.

7. Now run this python script by typing in:

   `python3 script.py . <TENANT_NAME> <GROUP_NAME>
   `
Doing this will replace all instances of <TENANT_NAME> and <GROUP_NAME> with your tenant name and group name. Do not push the changes yet.

### Apps of Apps structure

Now that we have renamed all the values and files that needed to changed, let's look at the structure of this repository.

  ![apps-of-apps-tree](images/apps-of-apps-tree.png)

1. At the root level, we have a `00-argocd-apps` folder and a `01-<TENAANT_NAME>`folder

2. Inside the `00-argocd-apps` folder there will be another `workshop` folder which represents the cluster name.

3. Inside the workshop folder, you will see multiple environments.

4. The environment folders contain argocd application for tenant that point to the particular tenant's environment.

5. In each tenant env folder, we will have argocd applciations for all the applications we want to deploy in a patricular environment. These apps will eventually point to a helm chart. 


### Deploying Nordmart


> Now we need to add a chart in the dev environment for deploying our application.

1. Navigate to 01-TENANT_NAME > 02-stakater-nordmart-review > 01-dev.

2. We need to add the Helm chart for the nordmart review here. Create a file named Chart.yaml here and paste in the following content.

```
apiVersion: v2
dependencies:
  - name: stakater-nordmart-review
    repository: https://nexus-helm-stakater-nexus.apps.devtest.vxdqgl7u.kubeapp.cloud/repository/helm-charts/
    version: 1.0.35
description: A Helm chart for Kubernetes
name: stakater-nordmart-review
version: 1.0.35

```

3. Now create a values.yaml and add the below content. 

```
stakater-nordmart-review:
  application:
    deployment:
      image:
        repository: nexus-docker-stakater-nexus.apps.devtest.vxdqgl7u.kubeapp.cloud/sorcerers/stakater-nordmart-review
        tag: 1.0.35

```
4. Once the above files are added, commit the changes, and push to the repository.


5. Now head over to argocd and search for <TENANT_NAME>-dev.


   ![search-argocd](images/search-argocd.png)


6. Open up the app and press sync. Once sync finishes, everything should have synced, `green` status. 


   ![sorceres-build](images/sorcerers-build.png)