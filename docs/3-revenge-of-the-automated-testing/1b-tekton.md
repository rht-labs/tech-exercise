## Extend Tekton Pipeline with Sonar Scanning

> In this section we are going to improve our already built pipeline and add SonarQube scanning to it.


1. Open the chart directory found in GitLab at `<TENANT_NAME>/nordmart-apps-gitops-config/01-<TENANT_NAME>/01-tekton-pipelines/00-build/`

  ![images/pipelines-Nordmart-apps-GitOps-config](images/pipelines-nordmart-apps-gitops-config.png)
  
2. Edit the `values.yaml` file. After the `stakater-create-git-tag-v1`, reference the SonarQube task and add a `runAfter` field to make it run after the create-git-tag-v1 task:

```yaml
- defaultTaskName: stakater-sonarqube-scanner-v1
  runAfter:
    - stakater-create-git-tag-v1

```
The pipeline will now become:
 ```yaml
   pipeline-charts:
     name: stakater-main-pr-v1
     workspaces:
     - name: source
       volumeClaimTemplate:
         accessModes: ReadWriteOnce
         resourcesRequestsStorage: 1Gi
     pipelines:
       tasks:
         - defaultTaskName: git-clone
         - defaultTaskName: stakater-create-git-tag-v1
         - defaultTaskName: stakater-sonarqube-scanner-v1
           runAfter:
             - stakater-create-git-tag-v1
         - defaultTaskName: stakater-buildah-v1
           name: build-and-push
           params:
             - name: BUILD_IMAGE
               value: "true"
         - defaultTaskName: stakater-helm-push-v1
         - defaultTaskName: stakater-create-environment-v1
         - defaultTaskName: stakater-gitlab-update-cd-repo-v1
           params: 
             - name: gitlab_group
         - defaultTaskName: stakater-push-main-tag-v1
     triggertemplate:
           serviceAccountName: stakater-workshop-tekton-builder
           pipelineRunNamePrefix: $(tt.params.repoName)-$(tt.params.prnumberBranch)
           params:
             - name: repoName
             - name: prnumberBranch
               default: "main"
     eventlistener:
           serviceAccountName: stakater-workshop-tekton-builder
           triggers:
           - name: gitlab-mergerequest-create
             bindings:
               - ref: stakater-gitlab-merge-request-v1
               - name: oldcommit
                 value: "NA"
               - name: newcommit
                 value: $(body.object_attributes.last_commit.id)
           - name: gitlab-mergerequest-synchronize
             bindings:
               - ref: stakater-gitlab-merge-request-v1
               - name: oldcommit
                 value: $(body.object_attributes.oldrev)
               - name: newcommit
                 value: $(body.object_attributes.last_commit.id)
           - name: gitlab-push
             bindings:
               - name: newcommit
                 value: $(body.after)
               - name: oldcommit
                 value: $(body.before)
               - ref: stakater-gitlab-push-v1
     rbac:
       enabled: false
     serviceAccount:
       name: stakater-workshop-tekton-builder
       create: false
 ```

4. Commit the changes.


5. Now open ArgoCD and check if the changes were synchronized. Click refresh if ArgoCD has not synced the changes yet.

![sonar](./images/sonar-argocd.png)
   
Open up the console and navigate to your pipeline definition by going to `Pipelines` and selecting your pipeline from the list. You should see a SonarQube task there as well.

![sonar-OpenShift](./images/sonar-openshift.png)

6. If the sync is green, you're good to go. You have successfully added SonarQube to your pipeline!

7. Now make a small change on the `stakater-nordmart-review` application to trigger the pipeline. Head over to the console and check the running pipeline. You should be able to see SonarQube task running.

![sonar-running](./images/sonar-running.png)

8. Once the task completes, head over to `sonarqube` by going to forecastle the opening sonarqube from there. Login using the SSO flow if prompted.

![sonar-running](./images/sonarqube-forecastle.png)

It will take you to the projects page. You should be able to see `stakater-nordmart-review` project in the console. 

![sonar-scanned](./images/sonar-scanned.png)


CONGRATULATIONS!!! SonarQube scanning is now integrated into your pipelines.
