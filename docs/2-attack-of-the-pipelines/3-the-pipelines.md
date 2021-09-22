## Pipelines

Why create pipelines:
* Assurance - drive up code quality and remove the need for dedicated deployment / release management teams
* Freedom - allow developers to take ownership of how and when code gets built and shipped
* Reliability - pipelines are a bit boring; they execute the same way each and every time they're run!
* A pathway to production:
  * Puts the product in the hands of the customer quicker
  * Enables seamless and repeatable deploys
  * More prod like infrastructure increases assurance
  * “We have already done it” behavior de-risks go live

### Choose your own adventure
Split into 2 groups within your team. Choose you own adventure! Each group will get to perform similar tasks:

| 🐈‍⬛ **Jenkins Group** 🐈‍⬛  |  🐅 **Tekton Group** 🐅 |
|-----------------------|----------------------------|
| * We need to fork PetBattle (clone from GitHub and push to GitLab) | * We need to fork PetBattle API (clone from GitHub and push to GitLab) |
| * Update Jenkinsfile task to leave out some stuff for participants | * Update Tekton task to leave out some stuff for participants |
| * Add webhook into GitLab repositories for triggering jobs | * Add webhook into GitLab repositories for triggering jobs |
| * Update `pet-battle/stage/values.yaml` && `pet-battle/test/values.yaml` with services information. (That's where two teams integrate their work.) | * Update `pet-battle/stage/values.yaml` && `pet-battle/test/values.yaml` with services information. (That's where two teams integrate their work.) 
| * By updating version files (pom.xml etc), kick the pipelines | * By updating version files (pom.xml etc), kick the pipelines |
| [jenkins](2-attack-of-the-pipelines/3a-jenkins.md) | [tekton](2-attack-of-the-pipelines/3b-tekton.md) |


🐈 <span style="color:purple;" >Expected Outcome</span>: Working pipelines that build the Pet Battle applications (front end and back) - yes .. **Cats** !! 🐈

![daisy-cat.png](images/daisy-cat.png)
