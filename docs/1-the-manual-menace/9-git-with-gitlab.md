# 🐡 Setting Up GitLab

Gitlab is an open-source DevSecOps platform with built-in version control, issue tracking, code review, and CI/CD,  giving developers the needed flexibility for managing their application development lifecycle. 

SAAP Instance comes with a fully managed instance of GitLab.

To access your GitLab instance, from your `Forecastle` console, click on the `GitLab` tile.

![forecastle-page](./images/forecastle-gitlab1.png)

You will be brought to the Gitlab Console.

![gitlab-home](./images/gitlab-home.png)

## Setting Up Your Gitlab

### Gitlab Group

Gitlab Groups allows you group related projects together. You can manage permissions for your projects, collaborate with your team members and view all issues relating to your project.

1. To create a group, click on `create a group` tile.


![gitlab-group](./images/gitlab-home-group.png)

2. Give your group a name and set the visibility level to `public`. You can also add team members.
Click on `create group` 

![gitlab-group-create](./images/create-group.png)

Your group has been created.

![gitlab-group-created](./images/gitlab-my-group.png)

### GitLab Projects

Gitlab Projects allow you group related codebases in one place for ease of collaboration, management and continuity. 

With your project, you can host your code  in repositories, track issues concerning them, make changes using the web IDE, implement CI & CD pipelines and integrate cloud services.

You will leverage Gitlab Projects to manage your application code.

1. To create a new project, from your group page, click on `New project`

![gitlab-new-project](./images/gitlab-new-project.png)

Our sample application to be deployed to your cluster, `Nordmart Review`, is a three-tier app consisting of;

1. Web User Interface
2. REST API
3. Database

> You will be importing three repositories containing the Nordmart review application and its configuration.

2. `Nordmart Review` is hosted in a git repository, which you can import by clicking on the `Import Project` tile.

![gitlab-new-import](./images/gitlab-import-project.png)


3. To import the `Nordmart Review` User Interface repository, click on the `Repository via URL` tile and input the following URL.

```
https://github.com/stakater-lab/stakater-nordmart-review-ui
```
add your project name and select `internal` for the visibility level. Then click `Create Project`

![gitlab-new-import](./images/nordmart-ui-import.png)

your project has been imported.

![nordmart-project](./images/nordmart-project.png)


4. Next, import the `Nordmart Review` RESTFUL API repository by repeating the previous steps. From your groups page, select `New Project` 

![gitlab-new-project](./images/gitlab-new-project.png)

5. Select the `Import Project` tile.

![gitlab-new-import](./images/gitlab-import-project.png)

6. Import the `Nordmart Review` RESTFUL API repository by clicking the `Repository via URL` tile and inputing the following URL. 

```
https://github.com/stakater-lab/stakater-nordmart-review

```

include your project name and select `internal` for your project visibility. Import your project by clicking on `Create Project`

![normart-review](./images/normart-review.png)

Your project has been imported.

![normart-review2](./images/nordmart-review.png)

7. Finally, import the `Nordmart Review` gitops configurations repository by also following the previous steps. From your groups page, click on `New Project`

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

### Making Changes to Your Code

GitLab `Personal Access Token` allows you interact safely with your GitLab repositories from remote enviroments. With your Personal Token, you can push changes directly to your GitLab projects from your workstation. Take the following steps to create your token and add it to your Dev enviroment.

1. Click on your profile icon at the top right corner of your page, and select `Edit profile`.

![edit-profile](./images/edit-profile.png)

2. At the left corner, Click on `Access Tokens`. You will be brought to the `Personal Access Token` Page

![access token](./images/access-token.png)

3. Give your token a name, as well as the `read_repository` and `write_repository` permissions. Then select `Create Personal Access Token`

![p_access token](./images/personal-access-token.png)

4. Once your Access Token has been created, make sure you copy it and keep in a safe place, as you  will not get a chance to view it again.


![p_access token2](./images/token.png)

5. Finally, add your Token to your Dev Workstation by saving them as the following enviroment variables.

```
export GIT_USER=<YOUR_TOKEN_NAME>
export GIT_TOKEN=<'YOUR_TOKEN>

```

![git-var](./images/git-var.png)














