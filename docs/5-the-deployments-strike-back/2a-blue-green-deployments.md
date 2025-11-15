## Extend Jenkins Pipeline with Blue/Green Deployments

In this exercise, we'll implement a blue/green deployment strategy for the Pet Battle application using Jenkins and Argo CD. Blue/green deployments allow you to run two identical production environments side-by-side, with only one serving live traffic at a time. This enables zero-downtime deployments and instant rollback capabilities.

### Understanding Blue/Green Deployments

In a blue/green deployment:
- **Blue Environment**: One production environment (currently active or inactive)
- **Green Environment**: Another identical production environment (currently active or inactive)
- **Active Service**: The service currently receiving production traffic
- **Inactive Service**: The service ready to receive the new deployment

The deployment process works as follows:
1. Deploy the new version to the currently inactive environment
2. Run tests to verify the deployment
3. Switch production traffic from the active to the newly deployed inactive service
4. Swap the active/inactive labels

This approach provides instant rollback—if something goes wrong, you simply switch traffic back to the previous environment. (For applications that don't persist data in the database, this is a good approach.)

---

## Implementing Blue/Green Deployment

We'll create two versions of the Pet Battle application (blue and green) and configure Jenkins to automatically manage the deployment and traffic switching process.

### Phase 1: Create Blue and Green Environments

**Step 1: Add Blue and Green Application Definitions**

Let's create two new deployments in our Argo CD repository for the Pet Battle frontend. We'll call one Blue and the other Green. Add two new applications in `tech-exercise/pet-battle/test/values.yaml`. Adjust the `source_ref` Helm chart version and `image_version` to match what you have built.

```bash
cat << EOF >> /projects/tech-exercise/pet-battle/test/values.yaml
  # Pet Battle UI Blue
  blue-pet-battle:
    name: blue-pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version - may need adjusting!
    values:
      image_version: latest # container image version - may need adjusting!
      fullnameOverride: blue-pet-battle
      blue_green: active
      # we control the prod route via the "blue" chart for simplicity
      prod_route: true
      prod_route_svc_name: blue-pet-battle
      config_map: '{
        "catsUrl": "https://pet-battle-api-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
        "tournamentsUrl": "https://pet-battle-tournament-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
        "matomoUrl": "https://matomo-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/",
        "keycloak": {
          "url": "https://keycloak-<TEAM_NAME>-test.<CLUSTER_DOMAIN>/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'

  # Pet Battle UI Green
  green-pet-battle:
    name: green-pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version - may need adjusting!
    values:
      image_version: latest # container image version - may need adjusting!
      fullnameOverride: green-pet-battle
      blue_green: inactive
      config_map: '{
        "catsUrl": "https://pet-battle-api-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
        "tournamentsUrl": "https://pet-battle-tournament-<TEAM_NAME>-test.<CLUSTER_DOMAIN>",
        "matomoUrl": "https://matomo-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/",
          "keycloak": {
          "url": "https://keycloak-<TEAM_NAME>-test.<CLUSTER_DOMAIN>/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'
EOF
```

> **Unsure how to adjust the `source_ref`?**<br>
> The `source_ref` is the version of the Helm chart. You can find your Helm charts in Nexus:<br>
> Navigate to: [https://nexus-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/#browse/browse:helm-charts:pet-battle](https://nexus-<TEAM_NAME>-ci-cd.<CLUSTER_DOMAIN>/#browse/browse:helm-charts:pet-battle)<br>
> Review all available versions and select the latest one.

> **Unsure how to adjust the `image_version`?**<br>
> The `image_version` is the tag of the image in the ImageStream. You can retrieve the image stream using the following command:<br>
> `oc get is -n <TEAM_NAME>-test pet-battle`<br>
> Review all available tags and select the latest one.

**Step 2: Deploy the Blue and Green Environments**

Commit the changes, and in the OpenShift UI, you'll see two new deployments coming alive:

```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m "🍔 ADD - blue & green environments 🍔"
git push
```

**Step 3: Verify the Service Labels**

Verify that each of the services contains the correct labels—one should be `active` and the other `inactive`. Our pipeline will push new deployments to the inactive one before switching the labels around:

```bash
oc get svc -l blue_green=inactive --no-headers -n <TEAM_NAME>-test
oc get svc -l blue_green=active --no-headers -n <TEAM_NAME>-test
```

You should see one service labeled as `active` (initially blue) and one labeled as `inactive` (initially green).

### Phase 2: Configure Jenkins Pipeline

**Step 4: Add Blue/Green Deployment Stage to Jenkinsfile**

With both environments deployed, let's update the `Jenkinsfile` to deploy to the `inactive` one. Jenkins will:
1. Overwrite the currently labeled `inactive` deployment with the new version
2. Run some tests (🪞💨) and verify that things are working correctly
3. Switch the traffic to the newly deployed service
4. Swap the labels so the newly deployed service becomes `active` and the previous one becomes `inactive`

The previous active service will be labeled `inactive` and wait, ready to switch back in case of an unwanted result.

To do this, add the following stage in the right placeholder:

```groovy
// 💥🔨 BLUE / GREEN DEPLOYMENT GOES HERE 
stage("🔷✅ Blue Green Deploy") {
  agent {
    label "jenkins-agent-argocd"
  }
  options {
     skipDefaultCheckout(true)
  }
  steps {
    echo '### set env to test against ###'
    sh '''
      #🌻 1. Get the current active / inactive
      export INACTIVE=$(oc get svc -l blue_green=inactive --no-headers -n ${DESTINATION_NAMESPACE} | cut -d' ' -f 1)
      export ACTIVE=$(oc get svc -l blue_green=active --no-headers -n ${DESTINATION_NAMESPACE} | cut -d' ' -f 1)

      #🌻 2. Deploy the new changes to hte current `inactive`
      printenv
      git clone https://${GIT_CREDS}@${ARGOCD_CONFIG_REPO} config-repo
      cd config-repo
      git checkout ${ARGOCD_CONFIG_REPO_BRANCH} # master or main
      yq eval -i .applications.\\"${INACTIVE}\\".source_ref=\\"${CHART_VERSION}\\" "${ARGOCD_CONFIG_REPO_PATH}"
      yq eval -i .applications.\\"${INACTIVE}\\".values.image_version=\\"${VERSION}\\" "${ARGOCD_CONFIG_REPO_PATH}"
      # Commit the changes :P
      git config --global user.email "jenkins@rht-labs.bot.com"
      git config --global user.name "Jenkins"
      git config --global push.default simple
      git add ${ARGOCD_CONFIG_REPO_PATH}
      git commit -m "🚀 AUTOMATED COMMIT - Deployment of ${APP_NAME} at version ${VERSION} 🚀" || rc1=$?
      git remote set-url origin  https://${GIT_CREDS}@${ARGOCD_CONFIG_REPO}
      git push -u origin ${ARGOCD_CONFIG_REPO_BRANCH}

      #🌻 3. do some kind of verification of the deployment  
      sleep 10
      echo "🪞💨 TODO - some kinda test to validate blue or green is working as expected ... 🪞💨"
      curl -k -L -f $(oc get route --no-headers ${INACTIVE//_/-} -n $DESTINATION_NAMESPACE | cut -d' ' -f 4) 

      #🌻 4. If "tests" have passed swap inactive to active to and vice versa
      yq eval -i .applications.\\"${INACTIVE}\\".values.blue_green=\\"active\\" "${ARGOCD_CONFIG_REPO_PATH}"
      yq eval -i .applications.\\"${ACTIVE}\\".values.blue_green=\\"inactive\\" "${ARGOCD_CONFIG_REPO_PATH}"

      #🌻 5. update the 'prod' route to point to the new active svc
      export NEW_ACTIVE=${INACTIVE//_/-}
      echo "🐥 - ${NEW_ACTIVE}"
      yq eval -i .applications.blue-pet-battle.values.prod_route_svc_name=\\"${NEW_ACTIVE}\\" "${ARGOCD_CONFIG_REPO_PATH}"
      git add ${ARGOCD_CONFIG_REPO_PATH}
      git commit -m "🚀 AUTOMATED COMMIT - Deployment of ${APP_NAME} at version ${VERSION} 🚀" || rc1=$?
      git remote set-url origin  https://${GIT_CREDS}@${ARGOCD_CONFIG_REPO}
      git push -u origin ${ARGOCD_CONFIG_REPO_BRANCH}
    '''
  }
}
```

> **How it works**: This Jenkins stage automatically:
> 1. Identifies which service is currently active and which is inactive
> 2. Deploys the new version to the inactive service
> 3. Verifies the deployment is working
> 4. Swaps the labels (making the new deployment active)
> 5. Updates the production route to point to the newly active service

### Phase 3: Make Visual Changes and Test

**Step 5: Modify the Header Component**

Before we commit the changes to the `Jenkinsfile`, let's make a simple application change to make this more visual. In the frontend, we'll change the banner along the top of the app. In your IDE, open `pet-battle/src/app/shell/header/header.component.html`. Uncomment the `<nav>` under the `<!-- PB - Purple -->` comment and remove the line above it so it appears like this:

```html
<header>
    <!-- PB - Purple -->
    <nav class="navbar  navbar-expand-lg navbar-dark" style="background-color: #563D7C;">
```

This change will make the new version visually distinct with a purple banner, making it easy to see which version you're viewing when testing.

**Step 6: Update the Application Version**

Bump the version of the application to trigger a new release by updating the `version` in the `package.json` at the root of the frontend's repository:

```json
{
  "name": "pet-battle",
  "version": "1.6.1",  // <- bump this version number
  "private": true,
  "scripts": ...
}
```

**Step 7: Commit and Push the Changes**

Commit all these changes:

!> **WARNING**<br>
If your IDE modified the `package-lock.json` file, make sure to not commit it to the repository. You can check which files were modified using the following command: `git status` inside the repository folder `cd /projects/pet-battle` and check the output.

```bash
cd /projects/pet-battle
git add .
git commit -m "🔵 ADD - Blue / Green deployment to pipeline 🟩"
git push
```

### Phase 4: Observe the Blue/Green Deployment

**Step 8: Watch the Deployment Process**

When Jenkins executes, you should see things progress and the blue/green deployment happen automatically. The pipeline will:
1. Deploy the new version to the currently inactive service
2. Run verification tests
3. Switch the production route to the newly deployed service
4. Swap the active/inactive labels

**Understanding the Three Routes:**

There are three routes available for accessing the application:
- **`prod-pet-battle`**: This is the production route that dynamically switches between the blue and green services. Jenkins controls which service this route points to based on which one is currently active.
- **`blue-pet-battle`**: This route is static and always points to the blue service, as configured in your `values.yaml` file.
- **`green-pet-battle`**: This route is static and always points to the green service, as configured in your `values.yaml` file.

**The Effect:**

The version in production is now the new `1.6.1` published with the latest change. As you can check from the nav bar of the application from the production route `prod-pet-battle` (currently linked to the `green` service):

![prod-pet-battle](images/bg-prod-pet-battle.png)

The previous `1.2.0` version, now identified as `blue`, is still available from the static blue route `blue-pet-battle`:

![blue-pet-battle](images/bg-blue-pet-battle.png)

**How It Works:**

Every time you change the `version` variable in the `package.json` file and trigger a new deployment, Jenkins will:
1. Deploy the new version to the currently inactive service (blue or green)
2. Run tests to verify the deployment
3. Switch the `prod-pet-battle` route to point to the newly deployed service
4. Swap the active/inactive labels

Try it by publishing a new version of the application, e.g: `1.6.2`. Which one is in production? Which is `blue`? Which is `green`?


> **Note**: This is a simple example to show how we can automate a blue/green deployment using GitOps. However, we did not remove the previous deployment of pet-battle; in the real world, you would clean up old deployments after a successful rollout.
