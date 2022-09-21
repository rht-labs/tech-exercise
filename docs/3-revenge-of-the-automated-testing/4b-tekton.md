## Extend Tekton Pipeline with Code Linting Task

## Integrate the pipeline with Tekton:
1. Open the Chart we added to 00-tekton-pipelines folder in section 2.

2. Open the values file in the editor. After the `stakater-sonarqube-scanner-v1`, reference the code-linting task and add a runAfter field to make it run after the stakater-sonarqube-scanner-v1 task:

```
- taskName: stakater-code-linting-v1
  runAfter:
    - stakater-sonarqube-scanner-v1

```
The pipeline will now become:
   ````
   apiVersion: v2
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
           params:
             - name: oldcommit
             - name: action
         - defaultTaskName: stakater-sonarqube-scanner-v1
           runAfter:
             - stakater-create-git-tag-v1
         - defaultTaskName: stakater-code-linting-v1
           runAfter:
            - stakater-sonarqube-scanner-v1
         - taskRef:
             task: stakater-build-image-flag-v1
             kind: ClusterTask
           name: stakater-build-image-flag-v1
           runAfter: 
             - stakater-create-git-tag-v1
           workspaces:
             - name: source
               workspace: source
           params:
             - name: oldcommit
             - name: newcommit
         - defaultTaskName: stakater-buildah-v1
           name: build-and-push
           runAfter:
            - stakater-build-image-flag-v1
              params:
               - name: BUILD_IMAGE
                 value: $(tasks.stakater-build-image-flag-v1.results.build-image)
               - name: IMAGE_REGISTRY
                 value: $(params.image_registry_url)
               - name: CURRENT_GIT_TAG
                 value: $(tasks.stakater-create-git-tag-v1.results.CURRENT_GIT_TAG)
         - defaultTaskName: stakater-helm-push-v1
         - defaultTaskName: stakater-update-cd-repo-v3
         - defaultTaskName: stakater-push-main-tag-v1
         - defaultTaskName: stakater-app-sync-and-wait-v1
           params:
             - name: timeout
               value: "120"
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
         - name: pullrequest-create
           interceptors:
           - ref:
               name: "cel"
             params:
               - name: "filter"
                 value: "(header.match('X-Gitlab-Event', 'Merge Request Hook') && body.object_attributes.action == 'open' )"
               - name: "overlays"
                 value:
                   - key: marshalled-body
                     expression: "body.marshalJSON()"
           bindings:
             - ref: stakater-gitlab-merge-request-v1
             - name: oldcommit
               value: "NA"
             - name: newcommit
               value: $(body.object_attributes.last_commit.id)
         - name: pullrequest-synchronize
           interceptors:
             - ref:
                 name: "cel"            
               params:
               - name: "filter"
                 value: "(header.match('X-Gitlab-Event', 'Merge Request Hook') && body.object_attributes.action == 'update' )"
               - name: "overlays"
                 value:
                   - key: marshalled-body
                     expression: "body.marshalJSON()"
           bindings:
             - ref: stakater-gitlab-merge-request-v1
             - name: oldcommit
               value: $(body.object_attributes.oldrev)
             - name: newcommit
               value: $(body.object_attributes.last_commit.id)
         - name: push
           interceptors:
             - ref:
                 name: "cel"
             params:
             - name: "filter"
               value: (header.match('X-Gitlab-Event', 'Merge Request Hook') && body.object_attributes.action == 'merge' )
             - name: "overlays"
               value:
                 - key: marshalled-body
                   expression: "body.marshalJSON()"
           bindings:
             - name: newcommit
               value: $(body.after)
             - name: oldcommit
               value: $(body.before)
             - ref: stakater-pr-v1
               kind: ClusterTriggerBinding
         - name: stakater-pr-cleaner-v2-pullrequest-merge
           create: false
     rbac:
       enabled: false
     serviceAccount:
       name: stakater-workshop-tekton-builder
        create: false

````
4. Commit the changes.
5. Now open Argocd and check if the changes were synchronized.
###### todo add screenshot
6. If the sync is green, you're good to go. You have successfully added code-linting to your pipeline!


