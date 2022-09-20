# Extend Tekton Pipeline with Stackrox

## Image scanning

We will be using roxctl, the command line interface for RHACS, for scanning our images.

Let's start by opening up the image scanning tasks already available in the SAAP cluster:

1. Once gain, open up the `Pipelines` section from the left menu and click `Tasks`, and then select ClusterTasks.

   ![cluster-tasks](./images/cluster-tasks.png)


2. Now type in rox-image-scan in the search box. You will see a task with the same name.

   ![rox-image-scan](./images/rox-image-scan.png)

3. Click on the task and open up its YAML.

   ![rox-image-scan-yaml](./images/rox-image-scan-yaml.png)

The task uses the `roxctl image scan` command to scan the image that we have built. Once scanning is finished, it prints the url that you can use to view the result.
We will see an example of this once we integrate the task to our pipeline and trigger the pipeline by making a change in the code.

To integrate the image scanning task into our pipeline, open up the existing pipeline definition in code ready workspace.

1. Add another task to the pipeline after the build-and-push task. The taskName should be `rox-image-scan` and it should run after the `build-and-push` and `stakater-sonnarqube-scanner-v1`
task.

```
- taskName: rox-image-scan
  runAfter:
    - build-and-push
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
         - taskName: stakater-set-commit-status-v1
           params:
           - name: state
             value: pending
         - taskName: git-clone
         - taskName: stakater-create-git-tag-v1
           params:
             - name: oldcommit
             - name: action
         - taskName: stakater-sonarqube-scanner-v1
           runAfter:
             - stakater-create-git-tag-v1
         - taskName: stakater-code-lint-v1
           runAfter:
            - stakater-sonarqube-scanner-v1
         - taskName: stakater-kube-linting-v1
           runAfter:
            - stakater-code-linting-v1
         - taskName: stakater-build-image-flag-v1
           runAfter:
            - stakater-create-git-tag-v1
              workspaces:
            - name: source
              workspace: source
              params:
               - name: oldcommit
               - name: newcommit
         - taskName: stakater-buildah-v1
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
         - taskName: rox-image-scan
           runAfter:
            - build-and-push
            - stakater-sonarqube-scanner-v1
         - taskName: stakater-comment-on-github-pr-v1
         - taskName: stakater-helm-push-v1
         - taskName: stakater-update-cd-repo-v3
         - taskName: stakater-push-main-tag-v1
         - taskName: stakater-app-sync-and-wait-v1
           params:
             - name: timeout
               value: "120"
       triggertemplate:
         serviceAccountName: stakater-tekton-builder
         pipelineRunNamePrefix: $(tt.params.repoName)-$(tt.params.prnumberBranch)
       eventlistener:
         serviceAccountName: stakater-tekton-builder
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
             - ref: stakater-pr-v1
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
             - ref: stakater-pr-v1
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
          name: stakater-tekton-builder
          create: false

````
4. Commit and push the changes to git.

5. Now open Argocd and check if the changes were synchronized.   


3. Lets try this in our pipeline. Edit `maven-pipeline.yaml` and add a step definition that runs after the **bake** image task. Be sure to adjust the **helm-package** task to `runAfter` the **image-scan** task:

    ```yaml
        # Image Scan
        - name: image-scan
          runAfter:
          - bake
          taskRef:
            name: rox-image-scan
          workspaces:
            - name: output
              workspace: shared-workspace
          params:
            - name: IMAGE
              value: "$(tasks.bake.results.IMAGE)"
            - name: WORK_DIRECTORY
              value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
            - name: OUTPUT_FORMAT
              value: table
    ```

    So you'll have a pipeline definition like this:
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
      ...
      # Image Scan
        - name: image-scan
          runAfter:
          - bake
          taskRef:
            name: rox-image-scan
      ...
      ...
      - name: helm-package
          taskRef:
            name: helm-package
          runAfter: <- make sure you update this❗❗
            - image-scan <- make sure you update this❗❗
      ...
    </code></pre></div>

4. Check in these changes.

    ```bash
    # git add, commit, push your changes..
    cd /projects/tech-exercise
    git add .
    git commit -m  "🔑 ADD - image-scan step to pipeline 🔑"
    git push 
    ```

5. Trigger a pipeline build.

    ```bash
    cd /projects/pet-battle-api
    git commit --allow-empty -m "🩴 test image-scan step 🩴"
    git push
    ```

    🪄 Observe the **pet-battle-api** pipeline running with the **image-scan** task.

## Check Build/Deploy Time Violations

?> **Tip** We could extend the previous check by changing the output format to **json** and installing and using the **jq** command. For example, to check the image scan output and return a results when the **riskScore** and **topCvss** are below a certain value say. These are better handled as *Build Policy* within ACS which we can check next.

1. Lets add another step to our **rox-image-scan** task to check for any build time violations.

    ```bash
    cd /projects/tech-exercise
    cat <<'EOF' >> tekton/templates/tasks/rox-image-scan.yaml
        - name: rox-image-check
          image: registry.access.redhat.com/ubi8/ubi-minimal:latest
          workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
          env:
            - name: ROX_API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: $(params.ROX_SECRET)
                  key: password
            - name: ROX_ENDPOINT
              valueFrom:
                secretKeyRef:
                  name: $(params.ROX_SECRET)
                  key: username
          script: |
            #!/usr/bin/env bash
            set +x
            export NO_COLOR="True"
            curl -k -L -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_ENDPOINT/api/cli/download/roxctl-linux --output roxctl  > /dev/null;echo "Getting roxctl"
            chmod +x roxctl > /dev/null
            ./roxctl image check --insecure-skip-tls-verify -e $ROX_ENDPOINT:443 --image $(params.IMAGE) -o json
            if [ $? -eq 0 ]; then
              echo "🦕 no issues found 🦕";
              exit 0;
            else
              echo "🛑 image checks failed 🛑";
              exit 1;
            fi
    EOF
    ```

2. Its not real unless its in git

    ```bash
    # git add, commit, push your changes..
    cd /projects/tech-exercise
    git add .
    git commit -m  "🐡 ADD - rox-image-check-task 🐡"
    git push
    ```

3. Trigger a pipeline run

    ```bash
    cd /projects/pet-battle-api
    git commit --allow-empty -m "🩴 test image-check step 🩴"
    git push
    ```

4. Our Pipeline should look like this now with two `image-scan` steps.

    ![acs-tasks-pipe.png](images/acs-tasks-pipe.png)

    🪄 Observe the **pet-battle-api** pipeline running with the **image-scan** task.

## Breaking the Build

Let's run through a scenario where we break/fix the build using a build policy violation.

1. Let's try breaking a *Build Policy* within ACS by triggering the *Build* policy we enabled earlier.

2. Edit the `pet-battle-api/Dockerfile.jvm` and add the following line under `EXPOSE 8080`:

    ```bash
    EXPOSE 22
    ```

3. Check in this change and watch the build that is triggered.

    ```bash
    # git add, commit, push your changes..
    cd /projects/pet-battle-api
    git add .
    git commit -m  "🐉 Expose port 22 🐉"
    git push
    ```

4. This should now fail on the **image-scan/rox-image-check** task.

    ![images/acs-image-fail.png](images/acs-image-fail.png)

5. Back in ACS we can also see the failure in the *Violations* view.

    ![images/acs-violations.png](images/acs-violations.png)

6. Remove the `EXPOSE 22` from the `Dockerfile.jvm` and check it in to make the build pass.

    ```bash
    cd /project/pet-battle-api
    git add .
    git commit -m  "🐧 FIX - Security violation, remove port 22 exposure 🐧"
    git push
    ```

🪄 Observe the **pet-battle-api** pipeline running successfully again.
