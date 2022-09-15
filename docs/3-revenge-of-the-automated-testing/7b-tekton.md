# Extend Tekton Pipeline with Stackrox (WIP)

## Integrate Rox Image Scan into pipeline
> With **StackRox**, you can analyze images for vulnerabilities. Scanner analyzes all image layers to check for known vulnerabilities by comparing them with the Common Vulnerabilities and Exposures (CVEs) list using **rox-image-scan**. You can also Check Build/Deploy Time Violations using **rox-image-check**

In this section we are going to improve our already built `main-pr-v1` pipeline and add Rox Image Scan task into the pipeline.  
The SAAP cluster is shipped with many useful predefined cluster tasks. 
Lets add two tasks into our pipeline  **rox-image-scan** and **rox-image-check**. 

1. To view the already defined Image Scanning/Checking Cluster Task, Open up the `Pipelines` section from the left menu and click `Tasks`

   ![cluster-tasks](./images/cluster-tasks.png)
    
2. Select `ClusterTasks`. A number of tasks will be displayed on your screen. Type in `rox-image-scan` in the search box that is displayed.
   You will see a  `rox-image-scan` task. Click to view details.

   ![rox-image-search](./images/rox-image-search.png)
   
3. CLick YAML to display the task definition.

   ![rox-image-scan-task](./images/rox-image-scan-task.png)  
   ![rox-image-check-task](./images/rox-image-check-task.png)

4. Open the Chart we added to 00-tekton-pipelines folder to our nordmart-apps-gitops-repository in section 2.

5. Open the `values.yaml` file in the editor. After the `build-and-push`, reference the rox-image-scan task. 

    ```
    - taskName: rox-image-check
    - taskName: rox-image-scan
    ```

    The pipeline will now become:
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
    pipeline-charts:
        name: stakater-main-pr-v1
        workspaces:
        - name: source
          volumeClaimTemplate:
          accessModes: ReadWriteOnce
          resourcesRequestsStorage: 1Gi
      pipelines:
        tasks:
          - taskName: git-clone
          - taskName: stakater-create-git-tag-v1
            params:
              - name: oldcommit
              - name: action
          - taskName: stakater-sonarqube-scanner-v1
          - taskName: stakater-buildah-v1
            name: build-and-push
                params:
                - name: BUILD_IMAGE
                  value: "true"
          <span style="color:#FA936A"># Add rox-image-scan after build-and-push
          - taskName: rox-image-check
          - taskName: rox-image-scan
          # End</span>
          - taskName: stakater-comment-on-github-pr-v1
          - taskName: stakater-helm-push-v1
          - taskName: stakater-update-cd-repo-v3
          - taskName: stakater-push-main-tag-v1
        eventlistener:
            serviceAccountName: stakater-tekton-builder
            triggers:
            - name: pullrequest-create
              bindings:
                - ref: stakater-pr-v1
                - name: oldcommit
                  value: "NA"
                - name: newcommit
                  value: $(body.object_attributes.last_commit.id)
            - name: pullrequest-synchronize
              bindings:
                - ref: stakater-pr-v1
                - name: oldcommit
                  value: $(body.object_attributes.oldrev)
                - name: newcommit
                  value: $(body.object_attributes.last_commit.id)
            - name: push
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
    </code></pre></div>
4. Now open Argocd and check if the changes were synchronized.

    TODO: Add screenshot

5. If the sync is green, you're good to go. You have successfully added rox-image-scan to your pipeline!
    TODO: See Pipeline

🪄🪄 Observe the **stakater-nordmart-review** pipeline running with the **rox-image-scan** & **rox-image-check** task.🪄🪄

🩴🔑🐉

## Breaking the Build

Let's run through a scenario where we break/fix the build using a build policy violation.

1. Let's try breaking a *Build Policy* within ACS by triggering the *Build* policy we enabled earlier.

2. Edit the `Dockerfile` and add the following line under `EXPOSE 8080`:

    ```bash
    EXPOSE 22
    ```

3. Check in this change and watch the build that is triggered.

    ```bash
    # git add, commit, push your changes..
    cd /projects/stakater-nordmart-review
    git add .
    git commit -m  "🐉 Expose port 22 🐉"
    git push
    ```

4. This should now fail on the **image-scan/rox-image-check** task.  
    TODO: Add screenshot
    ![images/acs-image-fail.png](images/acs-image-fail.png)

5. Back in ACS we can also see the failure in the *Violations* view.  
    TODO: Add screenshot
    ![images/acs-violations.png](images/acs-violations.png)

6. Remove the `EXPOSE 22` from the `Dockerfile` and check it in to make the build pass.

    ```bash
    cd /project/stakater-nordmart-review
    git add .
    git commit -m  "🐧 FIX - Security violation, remove port 22 exposure 🐧"
    git push
    ```

🪄 Observe the **stakater-nordmart-review** pipeline running successfully again.
