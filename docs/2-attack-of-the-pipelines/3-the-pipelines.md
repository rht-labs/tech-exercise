### The Pipelines 

Something something about automated pipelines
Create a repo in GitLab under <YOUR_TEAM_NAME> group called `pet-battle` Then fork the PetBattle API and PetBattle Frontend 

```bash
git clone https://github.com/rht-labs/pet-battle.git
git add fork https://<GITLAB_URL>/<YOUR_TEAM_NAME>/pet-battle.git
git checkout -b main
git push -u fork main
```

[TODO] a bit summary of what the pipeline does
Update `Jenkinsfile` by replacing <PLACEHOLDER> with the following:

```bash
[TODO] define what to add
```

Push the changes:

```bash
git add Jenkinsfile
git commit -m "Jenkinsfile updated"
git push
```

Set up Webhook for the repo to trigger Jenkins automatically. 
[TODO] add screenshots and guidance for it

Update the version of `package.json` and push it to trigger the pipeline.

```bash
git add package.json
git commit -m "Version bumped"
git push
```

OBSERVE PIPELINE RUNNING :D 


Split into groups and each group does
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile / Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml` with services information. That's where two teams integrate their works.
- By updating version files (pom.xml etc), kick the pipelines
- Question: should we only leave 'master/main' branch deployment
[TODO] decide what to leave out from Jenkinsfile