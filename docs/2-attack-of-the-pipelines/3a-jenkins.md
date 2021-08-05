### Jenkins Pipeline 

Something something about automated pipelines
Create a repo in GitLab under `<YOUR_TEAM_NAME>` group called `pet-battle` Then fork the PetBattle Frontend

```bash
cd /projects
git clone https://github.com/rht-labs/pet-battle.git && cd pet-battle
git remote set-url origin https://gitlab-ce.${CLUSTER_DOMAIN}/${TEAM_NAME}/pet-battle.git
git branch -M main
git push -u origin main
```

blah blah blah seed-job.... to make this work. Let's connect Jenkins to GitLab by exposing some variables on the deployment for it... we could of course just add them to the deployment in openshift BUTTTTTT this is GITOPS! :muscle: :nerd:
update the `ubiquitous-journey/values-tooling.yaml` Jenkins block / values 
<pre>
...
      deployment:
        env_vars:
          - name: GITLAB_HOST
            value: '<YOUR_GITLAB_HOST>'
          - name: GITLAB_GROUP_NAME
            value: '<YOUR_TEAM_NAME>'
</pre>

```bash
git push ... stuff
```

^ when this deploys we should see the seed job has scaffolded out our pipeline but it will fail on the first execution, this is expected as we're going write some stuff to fix it ...

With Jenkins now scanning our gitlab project for new repositories, we want to be able to tell Jenkins to run a build for every code change - welcome our good ol friend the Webhook. Just like we did with ArgoCD earlier, let's add a webhook to GitLab for our Pet-Battle front end so every commit triggers it. 

[TODO] add screenshots and guidance for it

So, with git setup to trigger a build on jenkins, now let's update our pipeline....

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

Push the changes:

```bash
cd /projects/pet-battle
git add Jenkinsfile
git commit -m "🌸 Jenkinsfile updated with build stage 🌸"
git push
```


🪄OBSERVE PIPELINE RUNNING :D 
🪄


Split into groups and each group does
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile / Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/stage/values.yaml` && `pet-battle/test/values.yaml` with services information. That's where two teams integrate their works.
- By updating version files (pom.xml etc), kick the pipelines
- Question: should we only leave 'master/main' branch deployment
[TODO] decide what to leave out from Jenkinsfile