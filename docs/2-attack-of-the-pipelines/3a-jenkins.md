### Jenkins Pipeline 
> Something something about automated pipelines and Jenkins. Pipeline as code, blah blah blah.

<!---
#### Jenkins access to GitLab
Jenkins needs to access repositories to see Jenkinsfile. There are multiple options to use ie username/password, SSH Keys and token (which we will going to use)

1. Login to GitLab and click on your avatar from upper left corner > Settings.
![gitlab-settings](images/gitlav-settings.png)
2. Click on Access Token and generate one.
![gitlab-access-token](images/gitlab-access-token.png)
3. Copy the newly generated token and update `ubiquitous-journey/values-tooling.yaml`
![gitlab-access-token-2](images/gitlab-access-token-2.png)

```bash
...
...
          - name: GITLAB_TOKEN
            value: ''
...
```

```bash
git add ubiquitous-journey/values-tooling.yaml
git commit -m "🥔 Gitlab Token is added 🥔"
git push
```
--->

#### Setup Pet Battle Git Repo
1. Create a repo in GitLab under `<YOUR_TEAM_NAME>` group called `pet-battle` Then fork the PetBattle Frontend.

```bash
cd /projects
git clone https://github.com/rht-labs/pet-battle.git && cd pet-battle
git remote set-url origin https://gitlab-ce.${CLUSTER_DOMAIN}/${TEAM_NAME}/pet-battle.git
git branch -M main
git push -u origin main
```


2. We want to be able to tell Jenkins to run a build for every code change - welcome our good ol' friend the Webhook. Just like we did with ArgoCD earlier, let's add a webhook to GitLab for our Pet Battle front end so every commit triggers it. Jenkins needs a url of the form `<JENKINS_URL>/multibranch-webhook-trigger/invoke?token=<APP_NAME>` to trigger a build:
```bash
# handy command to generate the url needed for the webhook :P
echo "\n https://$(oc get route jenkins --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)/multibranch-webhook-trigger/invoke?token=pet-battle"
```
[TODO] add screenshots and guidance for it

3. Commit the `pet-battle` application to the repository you just created:
```bash
cd /projects
git clone https://github.com/rht-labs/pet-battle.git && cd pet-battle
git remote set-url origin https://gitlab-ce.${CLUSTER_DOMAIN}/${TEAM_NAME}/pet-battle.git
git push -u origin main
```

#### Jenkins Pipeline
3. blah blah blah seed-job.... to make this work. Let's connect Jenkins to GitLab by exposing some variables on the deployment for it... we could of course just add them to the deployment in openshift BUTTTTTT this is GITOPS! :muscle: :gun:
update the `ubiquitous-journey/values-tooling.yaml` Jenkins block / values 
<pre>
...
      deployment:
        env_vars:
          - name: GITLAB_HOST
            value: https://gitlab-ce.<CLUSTER_DOMAIN>
          - name: GITLAB_GROUP_NAME
            value: '<TEAM_NAME>'
</pre>

4. Jenkins will push changes to our Helm Chart to Nexus as part of the pipeline. Originally we configured our App of Apps to pull from a different chart repository so we also need to update out Pet Battle `pet-battle/test/values.yaml` file to point to the Nexus chart repository deployed in OpenShift. Update the `source` as shown below for the `pet-battle-api`:
<pre>
  # Pet Battle Apps
  pet-battle-api:
		...

  pet-battle:
    name: pet-battle
    enabled: true
    source: <strong>http://nexus:8081/repository/helm-charts</strong>
    chart_name: pet-battle
    source_ref: 1.0.6 # helm chart version
    ...
</pre>

5. Commit your changes to git.
```bash
# git add, commit, push your changes..
cd /projects/tech-exercise
git add .
git commit -m  "🍕 ADD - jenkins pipelines config 🍕" 
git push
```
^ when this deploys we should see the seed job has scaffolded out in the Jenkins UI. Our pipeline but it will fail on the first execution, this is expected as we're going write some stuff to fix it ...
```bash
# to get the Jenkins route on your terminal
echo https://$(oc get route jenkins --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)
```
[TODO - screeenshot of Jenkins UI]

7. With Jenkins now scanning our gitlab project for new repositories and git setup to trigger a build on jenkins, now let's update our pipeline....
[TODO] a bit summary of what the pipeline does
blah blah blah structure of the Jenkinsfile... 

Now that we've gone through that this stuff does, let's update the `Jenkinsfile` by adding a new `stage` which will run our builds for us. Add the following below the  `// 💥🔨 PIPELINE EXERCISE GOES HERE ` comment:
```groovy
		// 💥🔨 PIPELINE EXERCISE GOES HERE 
		stage("🧰 Build (Compile App)") {
			agent { label "jenkins-agent-npm" }
			steps {
				script {
					env.VERSION = sh(returnStdout: true, script: "npm run version --silent").trim()
					env.PACKAGE = "${APP_NAME}-${VERSION}.tar.gz"
				}
				sh 'printenv'

				echo '### Install deps ###'
				sh 'npm ci --registry http://nexus:8081/repository/labs-npm'

				echo '### Running build ###'
				sh 'npm run build '

				echo '### Packaging App for Nexus ###'
				sh '''
					tar -zcvf ${PACKAGE} dist Dockerfile nginx.conf
					curl -v -f -u ${NEXUS_CREDS} --upload-file ${PACKAGE} \
						http://nexus:8081/repository/${NEXUS_REPO_NAME}/${APP_NAME}/${PACKAGE}
				'''
			}
		}
```

8. Push the changes to git:
```bash
cd /projects/pet-battle
git add Jenkinsfile
git commit -m "🌸 Jenkinsfile updated with build stage 🌸"
git push
```

9. Back on Jenkins we should now see the pipeline running. If you swap to the Blue Ocean view, you get a lovely graph of  what it looks like in execution.
[TODO] add screenshots and guidance for it


🪄OBSERVE PIPELINE RUNNING :D 🪄
