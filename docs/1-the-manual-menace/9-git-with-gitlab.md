# 🐡 Getting GitLab Ready for GitOps
> In this section we will get GitLab ready for our exercise. We will then import a couple of projects and prepare them for deployment to the cluster.

## About Stakater's Nordmart

Stakater's Nordmart of Stakater's fictitious e-commerce platform that we will deploy for the workshop. For simplicity, we will import only 2 microservices of Nordmart application as described in below sections.

## Importing Nordmart Review

  > In this section, we will import some existing projects that we are tasked with deploying on our tenant namespaces in the cluster.

1. Select `Menu` > `Projects` > `Create new project`. This will redirect you to the following screen. Select `Import Project`.

   ![create-project-home](images/create-project-home.png)

2. Now select the `Repository by URL` option and paste in the following repository URL:

    ```
    https://github.com/stakater-lab/stakater-nordmart-review.git
    ```

3. Change the `Project name` to `stakater-nordmart-review` > select your GitLab group to complete the `Project URL` and check the `Visibility Level` is `Public` then click `Create project`

   > Make sure you mark the repository as public and choose the group you previously created as the group name so we can easily find your work and help with any debugging. 
    
   > Make sure that Project Name is lower case and spaces are replaced with '-' so our automation doesn't break ;).  

   > Remember we are only making public repos with no branch protection or merge approval flows for sake of simplicity during the workshop. Branch Protection and one review must be configured in production. 

   ![import-Nordmart-review](images/import-nordmart-review.png)

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
