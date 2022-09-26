# KubeLinter

> KubeLinter is an open source tool that analyzes Kubernetes YAML files and Helm charts, checking them against a variety of best practices, with a focus on production readiness and security.

## Task

#### SAAP KubeLinter:

SAAP cluster is shipped with a `kube-lint` task that uses KubeLinter and Helm to verify the YAML files. We will be using this task to integrate KubeLinter in our pipeline.

Follow the below-mentioned procedure to add KubeLinter to the already deployed main-pr-v1 pipeline.

1. To view the already defined SonarQube cluster task, open up the `Pipelines` section from the left menu and click `Tasks`

![cluster-tasks](./images/cluster-tasks.png)


2. Select `ClusterTasks`. A number of tasks will be displayed on your screen. Type in `kube-lint` in the search box. You will see a task ` stakater-kube-linting-v1`

![Kube-lint-task](./images/kube-lint-task.png)

3. Click `YAML` to display the task definition.

   ![Kube-lint-yaml](./images/kube-lint-yaml.png)

The KubeLinter tasks has two steps:
* `helm` - this step uses Helm template and Helm dry run to check the Helm chart files.

![Helm-step-yaml](./images/helm-step.png)

* `kube-lint` - this step uses `kube-lint` to analyse the Kubernetes yaml files.

![Kube-lint-step-yaml](./images/kube-lint-step.png)

