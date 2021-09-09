### Pipelines
Split into 2 groups within your team. Choose you own adventure! Each group will get to perform similar tasks:

🐈‍⬛ `Jenkins Group` 🐈‍⬛
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/stage/values.yaml` && `pet-battle/test/values.yaml` with services information. (That's where two teams integrate their work.)
- By updating version files (pom.xml etc), kick the pipelines

🐅 `Tekton Group` 🐅
- we need to fork PetBattle API (clone from GitHub and push to GitLab)
- Update Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/stage/values.yaml` && `pet-battle/test/values.yaml` with services information. (That's where two teams integrate their work.)
- By updating version files (pom.xml etc), kick the pipelines

🐈 `Expected Outcome`: Working pipelines that build the Pet Battle applications - yes .. Cats !! 🐈

![daisy-cat.png](images/daisy-cat.png)
