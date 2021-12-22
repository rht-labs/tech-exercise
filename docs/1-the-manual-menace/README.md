# Exercise 1 - The Manual Menace
> A GitOps approach to perform and automate deployments.
## 👨‍🍳 Exercise Intro
In this exercise, we will use GitOps to set up our working environment. We will set up Git projects, create `dev`, `test` and `stage` projects in OpenShift, and deploy tools like Jenkins and Nexus to enable CI/CD in the next exercise. In order to do that, we'll use a popular approach called _GitOps_

## 🖼️ Big Picture
![big-picture-tools](images/big-picture-tools.jpg)

## 🔮 Learning Outcomes
* Understand the benefits gained from GitOps approach
* Deploy helm charts manually
* Drive tool installations through GitOps

## 🔨 Tools used in this exercise
* <span style="color:blue;">[Helm](https://helm.sh/)</span> - Helps us to define, install, and upgrade Kubernetes application.
* <span style="color:blue;">[ArgoCD](https://argoproj.github.io/argo-cd/)</span> - A controller which continuously monitors application and compare the current state against the desired
* <span style="color:blue;">[Nexus](https://www.sonatype.com/nexus-repository-sonatype)</span> - Repository manager for storing lots of application types. Can also host `npm` and `Docker` registries.
* <span style="color:blue;">[Jenkins](https://jenkins.io/)</span> - OpenSource Build automation server. Highly customisable with plugins.
