# Getting GitLab Ready for GitOps
> In this section we will get GitLab ready for our exercise. We will then import a couple of projects and prepare them for deployment to the cluster.

1. Navigate to [GitLab](https://gitlab.apps.devtest.vxdqgl7u.kubeapp.cloud/) and Sign-in if required. You can also go via the GitLab tile in [Forecastle](https://forecastle-stakater-forecastle.apps.devtest.vxdqgl7u.kubeapp.cloud). 

   First, we need to create a GitLab group with name as the `<TENANT_NAME>`

   For this open up the `Menu` and select `Groups` > `Create group`:

   ![create-group-tab](images/create-group-tab.png)

   This will redirect you to the following screen. Select `Create group`.

   ![create-group-home](images/create-group-home.png)

2. Use your `<TENANT_NAME>` as the group name, select `Public` for Visibility level > leave the rest of the defaults and click `Create group`.  

   ![GitLab-group-create](images/gitlab-group-create.png)

   GitLab will redirect you to the group's home page, once the group is created.

    > Remember that `group name` and should match your **tenant name**. 


3. If you are working as a team, and you haven't already done at group creation, you can add your colleagues to this group now.   

   This will give them permissions to work on the projects created in this group. Select `Group information` > `Members` from the left panel and invite your colleagues via `Invite member` option. Make sure to choose `Maintainer` or `Owner` role permission. You can ignore this step if you are not working as a team.

   Select `Group information` from the left panel and click `Members`

   ![add-member](images/add-member.png)

   Click `Invite members` and add your colleagues usernames or emails that they logged into GitLab with.

## Importing Nordmart Review

  > In this section, we will import some existing projects that we are tasked with deploying on our tenant namespaces in the cluster.

  > Nordmart Review is part of Stakater's fictitious e-commerce platform that we will deploy for the workshop.  

1. Select `Menu` > `Projects` > `Create new project`. This will redirect you to the following screen. Select `Import Project`.

   ![create-project-home](images/create-project-home.png)

2. Now select the `Repository by URL` option and paste in the following repository URL:

    ```
    https://github.com/stakater-lab/stakater-nordmart-review.git
    ```

3. Change the `Project name` to `stakater-nordmart-review` > select your GitLab group to complete the `Project URL` and check the `Visibility Level` is `Public` then click `Create project`

   > Make sure you mark the repository as public and choose the group you previously created as the group name so we can easily find your work and help with any debugging. 
    
   > Make sure that Project Name is lower case and spaces are replaced with '-' so our automation doesn't break ;).  

   > Remember we are only making public repos with no branch protection or merge approval flows for sake of simplicity during the workshop, these are very important settings that always should be used where appropriate. 

   ![import-Nordmart-review](images/import-nordmart-review.png)

3. Once you have imported the repository select the `.tronador.yaml` file from the repository root  

   ![Tronador](images/tronador1.png)

4. Edit the file via the `Open in Web IDE` and replace the existing tenant named `gabbar` with your tenant name and `Commit the changes to main`.   

   ![Tronador](images/tronador2.png)


## Importing Nordmart Review UI 



1. Select `Menu` > `Projects` > `Create new project`. This will redirect you to the following screen. Select `Import Project`.

   ![create-project-home](images/create-project-home.png)

2. Now select the `Repository by URL` option and paste in the following repository URL:

    ```
    https://github.com/stakater-lab/stakater-nordmart-review-ui.git
    ```

3. Change the `Project name` to `stakater-nordmart-review-ui` > select your GitLab group to complete the `Project URL` and check the `Visibility Level` is `Public` then click `Create project`

   > Make sure you mark the repository as public and choose the group you previously created as the group name so we can easily find your work and help with any debugging. 
    
   > Make sure that Project Name is lower case and spaces are replaced with '-' so our automation doesn't break ;).  

   > Remember we are only making public repos with no branch protection or merge approval flows for sake of simplicity during the workshop, these are very important settings that always should be used where appropriate. 

    ![import-Nordmart-review](images/import-nordmart-review-ui.png)

3. Once you have imported the repository select the `.tronador.yaml` file from the repository root.  
  
4. Edit the file via the `Open in Web IDE` and replace the existing tenant named `gabbar` with your tenant name and `Commit the changes to main`. 
