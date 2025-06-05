## Blue/Green Deployments

> Blue/Green deployments involve running two versions of an application at the same time and moving the traffic from the old version to the new version. Blue/Green deployments make switching between two different versions very easy.

<span style="color:blue;">[OpenShift Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/building_applications/deployments#deployments-blue-green_route-based-deployment-strategies)</span> is pretty good at showing an example of how to do a manual Blue/Green deployment. But in the real world you'll want to automate this switching of the active routes based on some test or other metric. Plus this is GITOPS! So how do we do a Blue/Green with all of this automation and new tech, let's take a look with our Pet Battle UI!

![blue-green-diagram](images/blue-green-diagram.jpg)

In your groups pick the tool you'd like to integrate the pipeline with:

| 🐈‍⬛ **Jenkins Group** 🐈‍⬛  |  🐅 **Tekton Group** 🐅 |
|-----------------------|----------------------------|
| * Add Blue/Green Deployments to our pipeline | * Add Blue/Green Deployments to our pipeline |
| <span style="color:blue;">[jenkins](5-the-deployments-strike-back/2a-blue-green-deployments.md)</span> | <span style="color:blue;">[tekton](docs/5-the-deployments-strike-back/2b-blue-green-deployments.md)</span> |
    