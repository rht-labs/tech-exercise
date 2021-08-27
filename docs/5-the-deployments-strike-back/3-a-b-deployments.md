### A/B Deployments
> Something something A/B deployment
[TODO] configmap - URL update

[OpenShift Docs](https://docs.openshift.com/container-platform/4.8/applications/deployments/route-based-deployment-strategies.html#deployments-ab-testing_route-based-deployment-strategies) is pretty good at showing an example of how to do a manual A/B deployment. But in the real world you'll want to automate this by increasing the load of the alternative service based on some tests or other metric. Plus this is GITOPS! So how do we do a A/B with all of this automation and new tech, let's take a look with our Pet Battle UI!

[TODO - ADD the DIAGRAM for what's happening]

1. Let's create two new deployments in our ArgoCD Repo for the pet-battle front end. One will have `a` suffix and the other will have `b` suffix. `a` is for currently running on production app, and `b` is for the one you are planning to direct the load gradually. A

dd 2 new application in `tech-exercise/pet-battle/test/values.yaml`.

```bash
cat << EOF > /projects/tech-exercise/pet-battle/test/values.yaml
  # Pet Battle UI - A
  pet-battle-a:
    name: pet-battle-a
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.1.0 # helm chart version
    values:
      image_version: latest # container image version
      fullnameOverride: pet-battle-a
      # this config will decide how much of the traffic will be routed for the alternate new version
      a_b_deploy:
        weight: 50
        svc_name: pet-battle-b

  # Pet Battle UI - B
  pet-battle-b:
    name: pet-battle-b
    enabled: true
    source: http://nexus:8081/repository/helm-charts
    chart_name: pet-battle
    source_ref: 1.1.0 # helm chart version
    values:
      image_version: latest # container image version
      fullnameOverride: pet-battle-b
      route: false
EOF
```

2. Git commit the changes and in OpenShift UI, you'll see two new deployments are coming alive.
```bash
cd /projects/tech-exercise
git add pet-battle/test/values.yaml
git commit -m  "🍿 ADD - A & B environments 🍿"
git push
```

3. Verify if you have the both service definition.
```bash
oc get svc -l app.kubernetes.io/name=pet-battle-a -n ${TEAM_NAME}-test
oc get svc -l app.kubernetes.io/name=pet-battle-b -n ${TEAM_NAME}-test
```

4. If you open up `pet-battle-a` in your browser, half of the traffic is going to `A`, and the half of the traffic is going to `B`.
```bash
oc get route/pet-battle-a -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

5. Now let's redirect 80% of the traffic to `B`, that means that only 20% of the traffic will go to `A`. So you need to update `weight` value in `tech-exercise/pet-battle/test/values.yaml` file. 
And as always, push it to the Git. Because if it's not in Git, it's not real!
```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-a.values.a_b_deploy.weight='20' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m  "🏋️‍♂️ service B weight increased to 80 🏋️‍♂️"
git push
```

6. Open an incognito browser and connect to the same URL. You'll get response from service `B` mostly.
```bash
oc get route/pet-battle-a -n ${TEAM_NAME}-test --template='{{.spec.host}}'
```

7. Lastly, let's redirect all traffic to service `B`. Yes, for that we need to make weight 0 for service `A`. 
```bash
cd /projects/tech-exercise
yq eval -i .applications.pet-battle-a.values.a_b_deploy.weight='0' pet-battle/test/values.yaml
git add pet-battle/test/values.yaml
git commit -m  "💯 service B weight increased to 100 💯"
git push
```

8. Now that we verify that this is working - we can look for embedd this approach into our pipelines. The steps would be like:

- deploy the new service
- run tests on it
- if successfull, increase the traffic by XX%
- run more tests / validate customer activity on the new service
- if successfull, increase the traffic by XX%
- repeat
- profit!