## Deploy App of Apps

We need a way to bundle up all of our applications and deploy them into each environment. The Nordmart application has its own Git repository and Helm chart, making it easier to code and deploy independently from other apps.

A developer can get the same experience and end result installing an application chart using `helm install` as our fully automated pipeline. This is important from a useability perspective. Argo CD has great support for all sorts of packaging formats that suit Kubernetes deployments, `Kustomize`, `Helm`, as well as just raw YAML files. Because Helm is a template language, we can mutate the Helm chart templates and their generated Kubernetes objects with various values allowing us to configure them with configuration per environment.

We deploy each of our applications using an Argo CD `application` definition. We use one Argo CD `application` definition for every environment in which we wish to deploy the application. We make use of Argo CD `app of apps pattern` to bundle all of these all up; some might call this an application suite or a system! In Nordmart we generate the app-of-apps definitions using a Helm chart.

### The apps of apps structure

> In this exercise we'll deploy `nordmart-review`. We'll deploy Nordmart to dev environment. And then get the build environment ready for deploying our pipelines

1. Head over to the below url.

   ```
   https://github.com/stakater-lab/nordmart-apps-gitops-config.git
    ```
    
This is the template that we will use to create our own apps-of-apps repository.
 

2. Copy the clone url.

   `https://github.com/stakater-lab/nordmart-apps-gitops-config.git`
 

3. Now open gitlab and select create project. In the screen that appears, choose `Import project`.

   ![clone-apps-config](images/clone-apps-config.png)


4. Select import repository from url and paste in the url that you copied in step 2. 

   Note: Make the repository public. Add `nordmart-apps-gitops-config` as the repository name. 
   > Make sure you mark the repository as public and choose the group you previously created as the group name.

   > Make sure that Project Name is lower case and doesnt contain spaces. Use '-' instead.

   ![import-gitops-apps](images/import-gitops-apps.png)

5. Once the repository is imported, clone the repository to your local system. 

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

5. In each tenant env folder, we will have argocd applciations for all the applications we want to deploy in a patricular environment. These apps will eventually point to a Helm chart. 


### Deploying Nordmart


> Now we need to add a chart in the dev environment for deploying our application.

1. Navigate to `01-TENANT_NAME > 02-stakater-nordmart-review > 01-dev`.

2. We need to add the Helm chart for the Nordmart review here. Create a file named Chart.yaml here and paste in the following content.

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

5. We are not done yet. We need to somehow connect this repository to an argocd application directly watched by the cluster. For this, head over to ``nordmart-infra-gitops-config

```https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/stakater/workshop-infra-gitops-config
```
We know that this repository is being watched by the cluster. So we will add an argocd application here and point it to our `nordmart-apps-gitops-config`

6. Navigate to workshop > nordmart-apps-gitops-config.
 
7. Add a file here named <TENANT_NAME>-nordmart-apps-gitops-config.yaml with the following content:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <TENANT_NAME>-nordmart-apps-gitops-config
  namespace: openshift-gitops
spec:
  destination:
    namespace: openshift-gitops
    server: 'https://kubernetes.default.svc'
  project: hogwarts
  source:
    path: 00-argocd-apps/01-workshop
    repoURL: https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/<TENANT_NAME>/nordmart-apps-gitops-config.git
    targetRevision: HEAD
    directory:
      recurse: true
  syncPolicy:
    automated:
      prune: true

```
Note: Replace all instance of <TENANT_NAME> with your tenant name in above file.

![nord-apps](images/nord-apps.png)

8. Now head over to argocd and search for <TENANT_NAME>-dev.


   ![search-argocd](images/sorcerers-dev.png)


9. Open up the app and press sync. Once sync finishes, everything should have synced, `green` status. 


   ![sorceres-build](images/sorcerers-build.png)