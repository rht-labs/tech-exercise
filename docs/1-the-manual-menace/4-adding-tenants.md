# infra-gitops-config

Infra gitops config contains the configuration for tenants. The tenants are created using tenant operator.
Tenant operator provides wrappers around OpenShift resources to provide a higher level of abstraction to the users. 
With Tenant Operator admins can configure Network and Security Policies, Resource Quotas, Limit Ranges, RBAC for every tenant, which are automatically inherited by all the namespaces and users in the tenant.
For the purpose of this workshop, we will consider each participant as a tenant.
An ArgoCD application syncs the changes made to the configuration. 

## Creating a Tenant

To create a tenant, participants are required to add a Tenant custom resource in the 'tenants' folder.

An example Tenant CR is provided below.

```
apiVersion: tenantoperator.stakater.com/v1beta1
kind: Tenant
metadata:
    name: participant
spec:
    quota: large
    owners:
        users:
        - participant@gmail.com
    argocd:
        sourceRepos:
            - 'https://github.com/stakater/infra-gitops-config'
    templateInstances:
        namespaces:
        - dev

```

Replace the name with your name.
Add your email to owner > users.
