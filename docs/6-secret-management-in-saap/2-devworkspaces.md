# Devworkspaces

Built on the open Eclipse Che project, Red Hat OpenShift Dev Spaces uses Kubernetes and containers to provide any member of the development or IT team with a consistent, secure, and zero-configuration development environment. The experience is as fast and familiar as an integrated development environment on your laptop.

OpenShift Dev Spaces is included with your OpenShift subscription and is available in the Operator Hub. It provides development teams a faster and more reliable foundation on which to work, and it gives operations centralized control and peace of mind.

Read More at https://access.redhat.com/products/red-hat-openshift-dev-spaces

## How we have setup devworkspaces (briefly)

A devworkspace is created automatically whenever a new user signs up as discussed in the previous section.

## How to access

In order to access your users devworkspace. Do the following steps:

1. Find the URL to openshift console via forecastle and Login to the cluster.

    --- Add Image ---

3. Open the search page from `Home > Search`, Click Resources and search `Devworkspace`. Select `Devworkspace` to show only `Devworkspace` resources. Make sure to change to sandbox project/namespace called <TENANT_NAME>-<USER_NAME>-<DOMAIN_NAME>-sandbox on the top e.g. if your are registered as rasheed@stakater.com, project name will be rasheed-rasheed-stakater-sandbox.

    --- Add Image ---

4. Open the Devworkspace resource in your sandbox namespace and click on yaml. Scroll down to `status` field and look for `mainURL` field. This URL is the link to your provisioned Devsworkspace as part of automation discussed earlier. Open the URL and verify if the Devworkspace is accessible.

    --- Add Image ---

## oc login to cluster

Your user is already logged to the cluster in the devworkspace. If you still have any issues, perform the following steps:

1. Find the URL to openshift console via forecastle and Login to the cluster.

    --- Add Image ---

2. Hover over the User Name displayed at top right corner of openshift console and select `Copy Login Command` from drop down menu. Click `Display` and copy the oc login command.

    --- Add Image ---

3. Open terminal on your DevSpace by pressing Ctrl+Shift+` or clicking Options > Terminal > New Terminal as highlighted below and paste the command copied in the previous step.

    --- Add Image ---

You are now successfully logged into the cluster.
## Switch between projects

