#🐡 Setting Up GitLab

Gitlab is an open-source DevSecOps platform with built-in version control, issue tracking, code review, and CI/CD,  giving developers the needed flexibility for managing their application development lifecycle. 

Your cluster comes with a fully managed instance of GitLab.

To access your GitLab instance, from your `Forecastle` console, click on the `GitLab` tile.

![permission-page](./images/forecastle-gitlab1.png)

You will be brought to the Gitlab Console.

![gitlab-home](./images/gitlab-home.png)

## Setting Up Your Gitlab

### Gitlab Groups

Gitlab Groups allows you group related projects together. You can manage permissions for your projects, collaborate with your team members and view all issues relating to your project.

1. to create a group, click on `create a group` tile 


![gitlab-group](./images/gitlab-home-group.png)

2. Give your group a name and set the visibility level to `public`. You can also add your team member. Next click on `create group` 

![gitlab-group-create](./images/create-group.png)

and your group has been created.

![gitlab-group-created](./images/gitlab-my-group.png)

### GitLab Projects

Gitlab Projects allow you to group related codebases in one place for ease of collaboration, management and continuity. 

With your project, you can host your code  in repositories, track issues concerning them, make changes using the web IDE, implement CI & CD pipelines and integrate cloud services.


You will leverage Gitlab Projects to manage our application code.

1. To create a new project, from your group page, click on `New project`

![gitlab-new-project](./images/gitlab-new-project.png)

Our sample application to be deployed to your cluster, `Nordmart Review`,is a three-tier app consisting of;

- User Interface
- Backend API
- Database

2. `Nordmart Review` is hosted in a git repository, you can import the application code by clicking on the `Import Project` tile

![gitlab-new-import](./images/gitlab-import-project.png)

3. To import the `Nordmart Review` User Interface application code, click on the `Repository via URL` tile and input the following URL.

```
https://github.com/stakater-lab/stakater-nordmart-review-ui
```
add your project name and select `internal` for the visibility level. Then click `Create Project`

![gitlab-new-import](./images/nordmart-ui-import.png)

your project has been imported.

![nordmart-project](./images/nordmart-project.png)


4. Next, import the `Nordmart Review` backend application code by repeating the previous steps. From your groups page, select `New Project` 

![gitlab-new-project](./images/gitlab-new-project.png)

5. Select the `Import Project` tile.

![gitlab-new-import](./images/gitlab-import-project.png)

6. Import the `Nordmart Review` backend application code by clicking the `Repository via URL` tile and inputing the following URL. 

```
https://github.com/stakater-lab/stakater-nordmart-review

```

include your project name and select `internal` for your project visibility. Import your project by clicking on `Create Project`

![normart-review](./images/normart-review.png)

Your project has been imported.

![normart-review2](./images/nordmart-review.png)

7. Finally, you will import the `Nordmart Review` gitops configurations by also following the previous steps. From your groups page, click on `New Project`

![gitlab-new-project](./images/gitlab-new-project.png)

then select `Import Project` tile.

![gitlab-new-import](./images/gitlab-import-project.png)

8. Import the `Nordmart Review` Gitops configuration  by clicking the `Repository via URL` tile and inputing the following URL. 

```
 https://github.com/stakater-lab/nordmart-apps-gitops-config-template
 
 ```
 
include your project name and select `internal` for your project visibility. Import your project by clicking on `Create Project`

![nordmart-gitops](./images/nordmart-gitops.png)

Your Project has been imported.


![nordmart-gitops-project](./images/nordmart-gitops-project.png)

9. You can see all your projects from your groups page.

![project](./images/projects.png)













