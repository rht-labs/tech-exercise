## A/B Deployments

> A/B deployments generally imply running two (or more) versions of the application at the same time for testing or experimentation purposes.

<span style="color:blue;">[OpenShift Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/building_applications/deployments#deployments-ab-testing_route-based-deployment-strategies)</span> provides a good example of how to do a manual A/B deployment. But in the real world, you'll want to automate this by increasing the load of the alternative service based on some tests or other metrics. Plus this is GitOps! So how do we do an A/B deployment with all of this automation and new tech? Let's take a look at our Pet Battle UI!

![a-b-diagram](images/a-b-diagram.jpg)

In your groups, pick the tool you'd like to integrate the pipeline with:

| 🐈‍⬛ **Jenkins Group** 🐈‍⬛  |  🐅 **Tekton Group** 🐅 |
|-----------------------|----------------------------|
| * Add A/B Deployments to our pipeline | * Add A/B Deployments to our pipeline |
| <span style="color:blue;">[jenkins](5-the-deployments-strike-back/3a-a-b-deployments.md)</span> | <span style="color:blue;">[tekton](5-the-deployments-strike-back/3b-a-b-deployments.md)</span> |
    