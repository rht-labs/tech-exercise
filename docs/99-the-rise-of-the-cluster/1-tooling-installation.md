## TL500 Cluster Setup

<p class="warn">
    ⛷️ <b>NOTE</b> ⛷️ - You need an OpenShift 4.8+ with cluster-admin privileges.
</p>

Just like we practice through out the course, we keep the cluster configuration as code in a GitHub repository: https://github.com/rht-labs/enablement-framework

This repository has two part:
- Helm charts to deploy some cluster-wide toolings
- CodeReady Workspaces setup

Let's clone the repository and prepare the cluster:

```bash
git clone https://github.com/rht-labs/enablement-framework
```

#### Helm Charts for Toolings

Here is the list of the tools and objects we deploy for TL500 setup:

* IPA - for user management - [prerequisite install](https://github.com/redhat-cop/containers-quickstarts/tree/master/ipa-server)
* CodeReady Workspaces - for developer environment.
* GitLab - as Git server
* SealedSecrets - for storing the secrets publicly safely. 
* StackRox - for image security exercises
* User Workload Monitoring - enable application metrics gathering. It is needed for `Return of the Monitoring` section.
* Logging - another cluster wide operator needs to be install beforehand
* Namespaces
* RBAC definition for attendees

A basic install looks like this:

```bash
cd enablement-framework/tooling/charts/tl500
helm dep up
helm upgrade --install tl500 . --namespace tl500 --create-namespace --timeout=15m
```

#### CodeReady Workspaces Setup

During the exercises, we use different commandlines like `oc`, `mvn`, `kube-linter` and many others. We have a container image that has all these necessary CLIs and, the configuration (Dockerfile) is under `codereadyworkspaces/stack/` folder.

We utilize GitHub Actions in order to build and store this image publicly. 

We have a `tl500-devfile.yaml` which is the _as code_ definition of our workspace. We refer to the container image inside the devfile:

```yaml
...
  - type: dockerimage
    alias: stack-tl500
    image: quay.io/rht-labs/stack-tl500:3.0.9
...
```

We have the explanation of how to get your own CodeRead Workspaces environment in the [first chapter](1-the-manual-menace/1-the-basics).