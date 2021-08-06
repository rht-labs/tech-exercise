## 🐙 ArgoCD - GitOps Controller
GitOps can be seen as a developer-centric approach to Ops. It teaches developers good practices around taking ownership of code once it leaves their machines and the approach to deploying and monitoring this code once it's running.

When practicing GitOps ideally, every action should be idempotent. Every action or operation can be applied multiple times, producing the exact same result. This is a very useful property in many situations, as it means that an operation can be repeated or retried as often as necessary without causing unintended effects. Configuration should be created declaratively. That is to say, you write the configuration to describe the desired state of an application or set of apps.

To implement a GitOps approach to our Helm charts, all we need to do is connect a tool to the Git repository, which can be alerted or watch for changes coming through. When those changes arrive, this tool can assess the difference between what the current state is and what state is desired and apply the changes automatically for
us. Enter ArgoCD.

From ArgoCD's website, it is described as a tool that:

<pre>
    automates the deployment of the desired application states in the specified target
    environments. Application deployments can track updates to branches, tags, or be pinned
    to a specific version of manifests at a Git commit.
</pre>

When something is seen as not matching the required state in Git, an application becomes out of sync. Depending on how you have implemented your GitOps, ArgoCD can then resync the changes to apply whatever is in Git immediately or fire a warning to initiate some other workflow. In the world of Continuous Delivery as implemented by ArgoCD, Git is the single source of truth, so we should always apply the changes as seen there.

### ArgoCD Basic Install
> ArgoCD is one of the most popular GitOps tools to keep the entire state of our OpenShift clusters as described in our git repos. ArgoCD is a fancy-pants controller that reconciles what is stored in our git repo (desired state) against what is live in our cluster (actual state). We can then configure it to do things based on these differences, such as auto sync the changes from git to the cluster or fire a notification to say things have gone out of whack.

1. To get started with ArgoCD, we've written a Helm Chart to deploy an instance of ArgoCD to the cluster. On your terminal, add the redhat-cop helm charts repository. This is a collection of charts used by consultants in the field. Pull requests welcomed :P
```bash
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts
```

2. Let's perform a basic install of basic install of ArgoCD. Using most of the defaults defined on the chart is sufficient for our usecase. When deploying many instances of ArgoCD in one shared cluster we need to set the `applicationInstanceLabelKey` uniquely for each ArgoCD deployment otherwise funky things start happening. We're are also going to configure ArgoCD to be allowed pull from our git repository using a secret that we'll configure later 🔐.

Configure our secret:
```bash
cat << EOF > /projects/tech-exercise/argocd-values.yaml
namespace: ${TEAM_NAME}-ci-cd
argocd_cr:
  applicationInstanceLabelKey: rht-labs.com/${TEAM_NAME}
  repositoryCredentials: |
    - url: https://gitlab-ce.apps.${CLUSTER_DOMAIN}
      type: git
      passwordSecret:
        key: password
        name: git-auth
      usernameSecret:
        key: username
        name: git-auth
EOF
```
Deploy ArgoCD:
```bash
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  -f /projects/tech-exercise/argocd-values.yaml \
  redhat-cop/argocd-operator
```

<p class="tip">
⛷️ <b>NOTE</b> ⛷️ - It's also worth noting we're allowing ArgoCD to run in a fairly permissive mode for these exercise, it can pull charts from anywhere. If you're interested in securing ArgoCD a bit more, checkout the <a href="/#/1-the-manual-menace/666-here-be-dragons?id=here-be-dragons">here-be-dragons</a> exercise at the end of this lab
</p>

3. If we check in OpenShift we should see the Operator pod coming to life and (eventually) the argocd-server, dex and other pods spin up.
```bash
oc get pods -w -n ${TEAM_NAME}-ci-cd
```
![argocd-pods](images/argocd-pods.png)

4. When all the pods are up and running, we can login to the UI of ArgoCD. Get the route and open it in a new browser tab. 
```bash
oc get route argocd-server --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd
```
![argocd-route](./images/argocd-route.png)

5. Login to ArgoCD by clicking `Log in via OpenShift` and use the OpenShift credentials provided.
![argocd-login](images/argocd-login.png)

6. Select `Allow selected permissions` for the initial login.
![argocd-allow-permission](images/argocd-allow-permission.png)

7. You just logged into ArgoCD 👏👏👏! Lets deploy a sample application through UI. On ArgoCD - click `CREATE APPLICATION` or `+ NEW APP`. You should see see an empty form. Let's fill it out by setting the folling:
   * On the "GENERAL" box
      * Application Name: `our-todolist`
      * Project: `default`
      * Sync Policy: `Automatic`
   * On the "SOURCE" box
      * Repository URL: `https://rht-labs.com/todolist/`
      * Select `Helm` from the right drop down menu
      * Chart: `todolist`
      * Version: `1.0.1` 
   * On the "DESTINATION" box
      * Cluster URL: https://kubernetes.default.svc
      * Namespace: `<TEAM_NAME>`-ci-cd

Your form should look like this:
![argocd-create-application](images/argocd-create-application.png)

8. After you hit create, you'll see `our-todolist` application is created and should start deploying in your `${TEAM_NAME}-ci-cd` namespace.
![argocd-todolist](images/argocd-todolist.png)

9. If you drill down into the application you will get ArgoCD's amazing view of all of the k8s resources that were generated by the chart
![argocd-todolist-detail](images/argocd-todolist-detail.png)

10. You can verify the application is running and behaving as expected by navigating to the url of the app, same way we did for the previous helm deploy.
```
oc get route/our-todolist -n ${TEAM_NAME}-ci-cd --template='{{.spec.host}}'
```

🪄🪄 Magic! You've now deployed ArgoCD and got it to manually deploy and application for you. Next up, we'll make ArgoCD do some *REAL* GitOps 🪄🪄