### Jenkins Pipeline 

Split into groups and each group does
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile / Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml` with services information. That's where two teams integrate their works.
- By updating version files (pom.xml etc), kick the pipelines
- Question: should we only leave 'master/main' branch deployment
[TODO] - add do500-sa to git repos to pull repos if repos not public