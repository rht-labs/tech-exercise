## 🔥🦄 Ubiquitous Journey
blah blah what it is, why we use it
Extensible, traceable, auditable ...
### Get GitLab Ready for GitOps
> In this exercise we'll setup our git project to store our code and configuration. We will then connect argocd (out gitOps controller) to this git repository to enable the GitOps workflow. Tooling will be shared by all members of your team, so do this exercise as a mob!
 
1. Log into GitLab (url provided by your facilitator) with your credentials. We need to create a group in GitLab as <TEAM_NAME>.  Click "Create a group" on the screen:
![gitlab-initial-login](images/gitlab-initial-login.png)

2. Put your <TEAM_NAME> as the group name, select `Internal` for Visibility level, and hit Create group. This is so we can easily share code and view other teams' activity.
![gitlab-create-group](images/gitlab-create-group.png)

3. Now lets create the git repository that we are going to use for <span style="color:purple;" >GIT</span>Ops purposes The `tech-exercise` will serve as a mono-repo holding both our tooling configuration and the application definitions. Hit `Create a project` button on the left hand side
![gitlab-new-project](images/gitlab-new-project.png)
 
4. On the new view, use `tech-exercise` as Project Name, select `Internal` for Visibility level, then hit Create project. Make sure the project is in the group you created previously and not the username's.
![gitlab-new-project](images/gitlab-new-project-2.png)

5. Back in your CodeReady Workspace, open a terminal if you have not got one open. Let's push our code to the GitLab server
```bash
cd /projects/tech-exercise
```
```bash
git remote set-url origin https://gitlab-ce.apps.${CLUSTER_DOMAIN}/${TEAM_NAME}/tech-exercise.git
```
```bash
git push -u origin --all
```

With our git project created and our configuration pushed to it - let's start our GitOps Journey 🧙‍♀️🦄!

### Deploy Ubiquitous Journey 🔥🦄
> something something what UJ is .... and what we're using it for in this exercise.

1. The Ubiquitous Journey (🔥🦄) is just another Helm Chart with a pretty neat pattern built in. But let's get right into it - update your `values.yaml` file to reference the git repo you just created and your team name. This is the default values that will be applied to all of the instances of this chart we create. The Chart's templates are not like the previous chart we used (services, deployments & routes) but an ArgoCD application definition, just like we manually created in the previous exercise.
```yaml
source: "https://gitlab-ce.apps.<CLUSTER_DOMAIN>/<TEAM_NAME>/tech-exercise.git"
team: <TEAM_NAME>
```

2. The `values.yaml` file refers to the `ubiquitous-journey/values-tooling.yaml` which is where we store all the definitions of things we'll need for our CI/CD pipelines. The definitions for things like Jenkins, Nexus, Sonar etc will all live in here eventually, but let's start small with two objects. One for boostrapping the cluster with some namespaces and permissions. And another to deploy our good friend Jenkins. Update your `ubiquitous-journey/values-tooling.yaml` by changing your `<TEAM_NAME>` in the bootstrap section appropriately
```yaml
        - name: jenkins
          kind: ServiceAccount
          role: admin
          namespace: <TEAM_NAME>-ci-cd
      namespaces:
        - name: <TEAM_NAME>-ci-cd
          bindings: *binds
        - name: <TEAM_NAME>-dev
          bindings: *binds
        - name: <TEAM_NAME>-test
          bindings: *binds
        - name: <TEAM_NAME>-stage
          bindings: *binds
```

3. This is GITOPS - so in order to affect change, we now need to commit things! Let's get the configuration into git, before telling ArgoCD to sync the changes for us.
```bash
# git add, commit, push your changes..
git add .
git commit -m  "🦆 ADD - correct project names 🦆" 
git push 
```

4. Install the tooling in Ubiquitous Journey (only bootstrap, and Jenkins at this stage..). Once the command is run, open the ArgoCD UI to show the resources being created. We've just deployed our first AppOfApps!
```bash
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .
```
![argocd-bootrstrap-tooling](./images/argocd-bootstrap-tooling.png)

5. As ArgoCD sync's the resources we can see them in the cluster:
```bash
oc get projects | grep ${TEAM_NAME}
```
```bash
oc get pods -n ${TEAM_NAME}-ci-cd
```

🪄🪄 Magic! You've now deployed an app of apps to scaffold our our tooling and projects in a repeatable and auditable way (via git!). Next up, we'll make extend the Ubiquitous Journey with some more tooling 🪄🪄
