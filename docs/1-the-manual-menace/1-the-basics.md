## 🐌 The Basics - CRW, OCP & Helm
## CodeReady Workspaces setup

1. Login to your CodeReadyWorkspace Editor. The link to this will be provided by your instructor.
![crw](./images/crw.png)

2. In your IDE, open a new terminal by hitting `Terminal > Open Terminal in Specific Container > do500-stack` from the menu.
![new-terminal](./images/new-terminal.png)

<!--@Cansu - this is how you style a colour on a word mid sentence <span style="color:purple;" >zsh</span>  -->
3. <strong>OPTIONAL</strong> - if you want to use `zsh` as opposed to `sh`, you can set it as the default shell by running. `zsh` is swish and all the cool kids are using it 😎!
```bash
echo "zsh" >> ~/.bashrc
```

4. Setup your `<TEAM_NAME>` name in the environment of the CodeReadyWorkspace by replacing this and running the command below. We will use the `TEAM_NAME` variable throughout the exercises so having it stored in our session means less changing of this variable throughout the exercises 💪:
```bash
# setup for commands
echo export TEAM_NAME="<TEAM_NAME>" | tee -a ~/.bashrc -a ~/.zshrc
```

5. Retrieve the `CLUSTER_DOMAIN` from the facilitator and add it to the environment
```bash
# setup cluster domain
echo export CLUSTER_DOMAIN="<CLUSTER_DOMAIN>" | tee -a ~/.bashrc -a ~/.zshrc
```

6. Verify the variables you have set
```bash
# verify variables
source ~/.bashrc
echo ${CLUSTER_DOMAIN}
echo ${TEAM_NAME}
```

7. Check if you can connect to OpenShift. The `<CLUSTER_DOMAIN>` should be provided by your facilitator. Update it and run the command below. 
```bash
# check if you can access the cluster
oc login --server=https://api.${CLUSTER_DOMAIN}:6443 -u <USERNAME> -p <PASSWORD>
```

8. Check your user permissions in OpenShift by creating your team's CICD project. 
```bash
# verify your can create a project
oc new-project ${TEAM_NAME}-ci-cd
```
![new-project](./images/new-project.png)
### Helm 101
> Helm is the package manager for Kubernetes. It provides a way to templatise the kubernetes yaml that make up our application. The Kubernetes resources such as `DeploymentConfig`, `Route` & `Service` can be processed by suppling `values` to the templates. In helm land there are a few ways to do this. A package containing the templates and their default values is called a chart. 

Let's deploy a simple application using helm.

1. Helm charts are packaged and stored in repositories. They can be added as dependencies of other charts or used directly. Let's add a chart repository now. The chart repository stores version history of our charts aswell as the tar file the chart is packaged as.
```
helm repo add do500 https://rht-labs.com/todolist/
```

2. Let's install a chart from this repo. First search the repositories to see what is available, then install the latest version. Helm likes to give each install a release, for conenience we've set ours to `my`. This will add a prefix of `my-` to all the resources that are created.
```bash
helm search repo todolist
```
```bash
helm install my do500/todolist --namespace ${TEAM_NAME}-ci-cd
```

3. Open the application up in the browser to verify it's up and running. Here's a handy one-liner to get the address of the app
```bash
oc get route/my-todolist -n ${TEAM_NAME}-ci-cd --template='{{.spec.host}}'
``` 
![todolist](./images/todolist.png)


4.  You can overwrite the default values in a chart from the command line, let's upgrade our deployment to show this. We'll make a simple change to the values. By default we only have one replica of our app, let's use helm to set this to 5.
```bash
# show only one pod for our my-todolist-1 release
oc get pods -n ${TEAM_NAME}-ci-cd
```
```bash
helm upgrade my do500/todolist --set replicas=5 --namespace ${TEAM_NAME}-ci-cd
```
```bash
# show five pods for our my-todolist-2 release
oc get pods -n ${TEAM_NAME}-ci-cd
```

5. If you're done playing with the #amazing-todolist-app then let's tidy up our work by removing the chart. To do this, run helm uninstall to remove our release of the chart.
```bash
helm uninstall my --namespace ${TEAM_NAME}-ci-cd
```
```bash
# verify the clean up
oc get pods | grep todolist
```

6. For those who are really interested, this is the annatomy of our helm chart. It can be [found here](https://github.com/rht-labs/todolist), but the basic structure is as follows
<pre>
todolist/chart
├── Chart.yaml
├── templates
│   ├── _helpers.tpl
│   ├── deploymentconfig.yaml
│   ├── route.yaml
│   └── service.yaml
└── values.yaml
</pre>
where:
* `Chart.yaml` - is the manifest of the chart. It defines the name, version and dependencies for our chart.
* `values.yaml` - is the sensible defaults for our chart to work, it contains the variables that are passed to the templates. We can over write these values on the command line
* `templates/*.yaml` - there are our k8s resources. 
* `_helpers.tpl` - is a collection of reusable variables an yaml snippets that are applied across all of the k8s resources uniformly for example, labels are defined in here and included on each k8s resource file as necessary.

### TODO - Familiarise yourself with some basic helm...
    * thinking add some random chart / website / app eg Residency Microsite? 
    * change values eg defaults and then override on the command line
    * show values changed?
