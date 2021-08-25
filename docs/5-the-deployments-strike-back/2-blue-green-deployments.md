### Blue/Green Deployments
> Something something blue green deployment


[OpenShift Docs](https://docs.openshift.com/container-platform/4.8/applications/deployments/route-based-deployment-strategies.html#deployments-blue-green_route-based-deployment-strategies) is pretty good at showing an example of how to do a manual Blue/Green deployment. But in the real world you'll want to automate this switching of the active routes based on some test or other metric. Plus this is GITOPS! So how do we do a Blue/Green with all of this automation and new tech, let's take a look with our Pet Battle UI!

[TODO - ADD the DIAGRAM for what's happening]

1. Let's create two new deployments in our ArgoCD Repo for the pet-battle front end. We'll call one Blue and the other Green. Add 2 new application in `tech-exercise/pet-battle/test/values.yaml`.

```bash
cat << EOF > /projects/tech-exercise/pet-battle/test/values.yaml
  # Pet Battle UI Blue
  blue-pet-battle:
    name: blue-pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.1.0 # helm chart version
    values:
      image_version: latest # container image version
      fullnameOverride: blue-pet-battle
      blue_green: active
      # we controll the prod route via the "blue" chart for simplicity
      prod_route: true
      prod_route_svc_name: blue-pet-battle

  # Pet Battle UI Green
  green-pet-battle:
    name: green-pet-battle
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.1.0 # helm chart version
    values:
      image_version: latest # container image version
      fullnameOverride: green-pet-battle
      blue_green: inactive
EOF
```

2. Git commit the changes and in OpenShift UI, you'll see two new deployments are coming alive.
```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m  "🍔 ADD - blue & green environments 🍔"
git push
```

3. Verify each of the services contains the correct labels - one should be `active` and the other `inactive`. Our pipeline will push new deployments to the inactive one before switching the labels around:
```bash
oc get svc -l blue_green=inactive --no-headers -n ${TEAM_NAME}-test
oc get svc -l blue_green=active --no-headers -n ${TEAM_NAME}-test
```

4. Let's verify if we can switch the traffic from Blue to Green. First grab each `INACTIVE` and `ACTIVE` endpoint from the service labels 
```bash
export INACTIVE=$(oc get svc -l blue_green=inactive --no-headers -n ${TEAM_NAME} | cut -d' ' -f 1)
export ACTIVE=$(oc get svc -l blue_green=active --no-headers -n ${DESTINATION_NAMESPACE} | cut -d' ' -f 1)
echo "INACTIVE == ${INACTIVE} / ACTIVE == ${ACTIVE}"
```

5. Patch the deployment with a new image version

4. Let's Update the `Jenkinsfile` to do the deployment for the `inactive` one - and in this case, it is Blue. Jenkins will run some tests (🪞💨) and verify the Blue environment working fine and switch the traffic to it. Green will become inactive and wait ready to switch back in case of an unwanted result.

In order to do that, add the below stage in the right placeholder:

<p class="tip">
⛷️ <b>NOTE</b> ⛷️ - There is always room for improvement :D 
</p>

```groovy
stage("🔷✅ Blue Green Deploy") {
			agent {
				label "jenkins-agent-argocd"
			}
			steps {
				echo '### set env to test against ###'
				sh '''
					export INACTIVE=$(oc get svc -l blue_green=inactive --no-headers -n ${DESTINATION_NAMESPACE} | cut -d' ' -f 1)
					export ACTIVE=$(oc get svc -l blue_green=active --no-headers -n ${DESTINATION_NAMESPACE} | cut -d' ' -f 1)

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

					sleep 10
					echo "🪞💨 TODO - some kinda test to validate blue or green is working as expected ... 🪞💨"
					curl -L -f $(oc get route --no-headers ${INACTIVE//_/-} -n $DESTINATION_NAMESPACE | cut -d' ' -f 4) 

					# IF "tests" have passed swap blue to green or vice versaw
					yq eval -i .applications.\\"${INACTIVE}\\".values.blue_green=\\"active\\" "${ARGOCD_CONFIG_REPO_PATH}"
					yq eval -i .applications.\\"${ACTIVE}\\".values.blue_green=\\"inactive\\" "${ARGOCD_CONFIG_REPO_PATH}"

					# # 5 update the 'prod' route to point to $INACTIVE
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