# 🐓 Tenant Operator 101

Stakater’s Tenant-Operator makes it easy to implement multi-tenancy in your organisation. When Network and Security Policies, Resource Quotas, Limit Ranges, and RBAC are configured for a tenant, all the namespaces and users inherit these policies.

Tenant-Operator custom resources, you can help your developers self-service, reliving your admins of some engineering toil.

With your Tenant Operator, You can configure the following custom resources;

- Tenants
- Quotas
- Templates for your application deployments
- ResourceSupervisor
- Namespaces

Tenant-Operator resources is designed 100% cloud-native, this means that you can manage your tenants as code allowing you to integrate Gitops into your multi-tenancy workflow.

## Creating Tentants with Gitop

The following Repository contains ArgoCD app configurations to help automate the creation of your tenant.

1. From the repository, click on the `workshop` folder.

![mto-workshop](./images/mto-workshop.png)


The `workshop` folder contains the following folders:

- `argocd-apps` This contains all the argocd apps “watching” your repositories.

- `nordmart-apps-gitops-config` Which containing the argocd configuration “watching” your apps

- `tenant-operator-config` which contains your Tenants configurations.


2. Click on the `tenant-operator-config` folder.

![mto-config](./images/mto-config.png)


3. Click on the `tenants` folder.

![mto-tenants](./image/mto-tenants.png)

> The `tenants` folder contains the configuration for all the tenants in your SAAP managed instance.

4. Click the `+`icon to create a new  yaml file. This file will contain your tenant configurations.

![mto-file](./image/mto-file.png)

4. Paste the code below to create a new tenant with a user, a list of argoCD “watched” repositories belonging to the tenant and its accompanying namespaces.

```yaml
apiVersion: tenantoperator.stakater.com/v1beta1
kind: Tenant
metadata:
  name: <INSERT_YOUR_TENANT_NAME>
spec:
  quota: workshop-medium
  owners:
    users:
      - <INSERT_YOUR_USER_NAME>
  argocd:
    sourceRepos:
      - 'https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/dominators/workshop-infra-gitops-config.git'
      - 'https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/genesis/nordmart-apps-gitops-config.git'
      - 'https://stakater.github.io/stakater-charts'
  namespaces:
  - dev
  - build
  - test
  - prod
```

5. Select `commit changes` to create your tenant. ArgoCD automates the creation of tenants by syncing your desired state with the actual state of your SAAP instance.

![mto-commit](./image/mto-commit.png)