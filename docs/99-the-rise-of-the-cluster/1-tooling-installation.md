## TL500 Cluster Setup

<p class="warn">
    ⛷️ <b>NOTE</b> ⛷️ - You need an OpenShift 4.9+ cluster with cluster-admin privilege.
</p>

Just like we practice through out the course, we keep the cluster configuration as code in a GitHub repository: https://github.com/rht-labs/enablement-framework

This repository has two part:
- Helm charts to deploy some cluster-wide toolings to run the exercises
- Red Hat CodeReady Workspaces setup

Let's clone the repository and prepare the cluster:

```bash
git clone https://github.com/rht-labs/enablement-framework
```

#### Helm Charts for Toolings

Here is the list of the tools and objects we deploy on OpenShift for TL500 setup:

* Red Hat CodeReady Workspaces - developer environment
* GitLab - as Git server
* SealedSecrets - for storing the secrets publicly safely. 
* StackRox - for image security exercises
* User Workload Monitoring - to enable application metrics gathering. It is needed for `Return of the Monitoring` section.
* Logging stack - it is not enabled by default in OpenShift. We enable it for `Return of the Monitoring` section.
* Some shared namespaces to install above components
* RBAC definition for `student` group

All of them are defined as one helm chart in the repository. You can update [`values.yaml`](https://github.com/rht-labs/enablement-framework/blob/main/tooling/charts/tl500/values.yaml) locally if you'd like to change some naming or skip to install some components.

A basic install looks like this:

```bash
cd enablement-framework/tooling/charts/tl500
helm dep up
helm upgrade --install tl500 . --namespace tl500 --create-namespace --timeout=15m
```

#### User Management
Students do not have cluster-admin privilege on the cluster. We have an OpenShift user group called `student` which have an RBAC definition applied in order to run the exercises successfully.
You can choose to use your own user management system. You can create a group called `student` and add the students to it. 

#### Verify The Installation
Log in to the cluster via UI and use `ldap` login with your student username and password. You should only see `tl500-*` namespaces. 

#### CodeReady Workspaces Setup

During the exercises, we use different commandlines like `oc`, `mvn`, `kube-linter` and many others. We have a container image that has all these necessary CLIs and, the configuration (Dockerfile) is under `codereadyworkspaces/stack/` folder.

We utilize GitHub Actions in order to build and store this image publicly. 

There is a `tl500-devfile.yaml` which is the _as code_ definition of our workspace. We refer to the container image inside the [devfile](https://github.com/rht-labs/enablement-framework/blob/main/codereadyworkspaces/tl500-devfile.yaml#L29):

```yaml
...
  - type: dockerimage
    alias: stack-tl500
    image: quay.io/rht-labs/stack-tl500:3.0.10
...
```

We have the explanation of how to get your own CodeRead Workspaces environment in the [first chapter](1-the-manual-menace/1-the-basics).