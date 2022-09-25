# Getting GitLab Ready for GitOps
> In this section we will get GitLab ready for our exercise. We will then import a couple of projects and prepare them for deployment to the cluster.

1. Navigate to [GitLab](https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/) and Sign-in if required. You can also go via the GitLab tile in [Forecastle](https://forecastle-stakater-forecastle.apps.devtest.vxdqgl7u.kubeapp.cloud). 

   First, we need to create a GitLab group with name as the `<TENANT_NAME>`

   For this open up the `Menu` and select `Groups` > `Create group`:

   ![create-group-tab](images/create-group-tab.png)

   This will redirect you to the following screen. Select `Create group`.

   ![create-group-home](images/create-group-home.png)

2. Use your `<TENANT_NAME>` as the group name, select `Public` for Visibility level > leave the rest of the defaults and click `Create group`.  

   ![gitlab-group-create](images/gitlab-group-create.png)

   GitLab will redirect you to the group's home page, once the group is created.

    > Remember that `group name` and should match your **tenant name**. 


3. If you are working as a team, and you haven't already done at group creation, you can add your colleagues to this group now.   

   This will give them permissions to work on the projects created in this group. Select `Members` from the left panel and invite your colleagues via `Invite member` option. Make sure to choose `Maintainer` or `Owner` role permission. You can ignore this step if you are not working as a team.

   To do this, select `Group information` from the left panel and click `Members`

   ![add-member](images/add-member.png)

   Click `Invite members` and add your colleagues usernames or emails that they logged into gitlab with.

## Importing Nordmart Review
> In this part, we will import the projects we need to deploy on the cluster.

1. Select "Projects" from the menu and click "Create project". This will redirect you to the following screen. Select "Import Project".
   ![create-project-home](images/create-project-home.png)

2. Now select the "Repository by URL" option and paste in the following repository URL:
    ```
    https://github.com/stakater-lab/stakater-nordmart-review.git
    ```
   > Make sure you mark the repository as public and choose the group you previously created as the group name. 
    
   > Make sure that Project Name is lower case and doesn't contain spaces. Use '-' instead.  

   ![import-Nordmart-review](images/import-nordmart-review.png)

3. Once you have imported the repository, open the .tronador file present at the base and replace the tenant field with your tenant.

   ![tronador](images/tronador1.png)


   ![tronador](images/tronador2.png)


## Importing Nordmart Review UI 
1. Select "Projects" from the menu and click "Create project". This will redirect you to the following screen. Select "Import Project".
   ![create-project-home](images/create-project-home.png)

2. Now select the "Repository by URL" option and paste in the following repository URL:
    ```
    https://github.com/stakater-lab/stakater-nordmart-review-ui.git
    ```
   > Make sure you mark the repository as public and choose the group you previously created as the group name.
   
   > Make sure that Project Name is lower case and doesnt contain spaces. Use '-' instead.
    
    ![import-Nordmart-review](images/import-nordmart-review-ui.png)

3. Once you have imported the repository, open the .tronador file present at the base and replace the tenant field with your tenant_ 
