# Exercise 2 - Attack of the Pipelines

- [] Add Intro to section
- [] Add Learning Objectives
- [] Add Big Picture?

## 🔨 Tools used in this exercise!
* [SealedSecrets]
* [Jenkins]
* [Nexus]
* [Tekton]

## Deploy PetBattle

[TODO] Little introduction to PetBattle


### 1. SealedSecrets 
* [copy + paste from previous ex]


### 2. Deploy supporting infra components for PetBattle
Deploy an piece of supporting tech or "infra" for PB - keycloak in `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml`




### 3 - The Pipelines 

Split into groups and each group does
- we need to fork PetBattle (clone from GitHub and push to GitLab)
- Update Jenkinsfile / Tekton task to leave out some stuff for participants
- Add webhook into GitLab repositories for triggering jobs
- Update `pet-battle/staging/values.yaml` && `pet-battle/test/values.yaml` with services information. That's where two teams integrate their works.
- By updating version files (pom.xml etc), kick the pipelines
- Question: should we only leave 'master/main' branch deployment
[TODO] decide what to leave out from Jenkinsfile