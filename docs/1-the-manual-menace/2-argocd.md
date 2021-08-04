## 🐙 ArgoCD - GitOps Controller
Blah blah blah stuff GitOps and why we use it...

blah blah blah stuff about Operators and Helm and what they provide us.

### ArgoCD Basic install
> ArgoCD is one of the most popular GitOps tools to keep the entire state of our OpenShift clusters as described in our git repos. ArgoCD is a fancy-pants controller that reconciles what is stored in our git repo (desired state) against what is live in our cluster (actual state). We can then configure it to do things based on these differences, such as auto sync the changes from git to the cluster or fire a notification to say things have gone out of whack.

1. To get started with ArgoCD, we've written a Helm Chart to deploy an instance of ArgoCD to the cluster. On your terminal, add the redhat-cop helm charts repository. This is a collection of charts used by consultants in the field. Pull requests welcomed :P
```bash
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts
```

2. Let's perform a basic install of basic install of ArgoCD. Using most of the defaults defined on the chart is sufficient for our usecase. However, things to be weary of with many ArgoCD instances in one shared cluster is the `applicationInstanceLabelKey`. This needs to be unique for each ArgoCD deployment otherwise funky things start happening.

<!-- weird bug alert! having a newline here makes the docsify render happy, but having the commands starting with "--" and no new line causes it to run on  -->
```bash
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  --set namespace=${TEAM_NAME}-ci-cd \
  --set argocd_cr.applicationInstanceLabelKey=rht-labs.com/${TEAM_NAME} \
  redhat-cop/argocd-operator
```

<p class="tip">
⛷️ <b>NOTE</b> ⛷️ - It's also worth noting we're allowing ArgoCD to run in a fairly permissive mode for these exercise, it can pull charts from anywhere. If you're interested in securing ArgoCD a bit more, checkout the <a href="/#/1-the-manual-menace/666-here-be-dragons?id=here-be-dragons">here-be-dragons</a> exercise at the end of this lab
</p>


1. Stuff here
```bash
oc get pods -w -n ${TEAM_NAME}-ci-cd
```

can login and check _nothing is deployed_

```bash
oc get route.....
```
Login to ArgoCD by clicking `Log in via OpenShift` and use the credentials.
![argocd-login](images/argocd-login.png)

Select `Allow selected permissions` for the initial login.
![argocd-allow-permission](images/argocd-allow-permission.png)

You just logged into ArgoCD! Lets deploy a sample application through UI. On ArgoCD - click `CREATE APPLICATION` or `+ NEW APP`. You should see see an empty form. Let's fill it out. Set the folling:
* Application Name: my-todolist 
* Project: default
* Sync Policy: Automatic

* Repository URL: https://rht-labs.com/todolist/
    (and select Helm from the right drop down menu)
* Chart: todolist
* Version: 1.0.1 

* Cluster URL: https://kubernetes.default.svc
* Namespace: <TEAM_NAME>-ci-cd

Your form should look like this:
![argocd-create-application](images/argocd-create-application.png)

After you hit create, you'll see `my=todolist` application is created and start deploying in your `${TEAM_NAME}-ci-cd` namespace.
![argocd-todolist](images/argocd-todolist.png)
