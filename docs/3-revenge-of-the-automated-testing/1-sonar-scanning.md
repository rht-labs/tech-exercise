# Sonar Scanning
> what is it why important, activity, acceptance createria

### Feature - SonarQube
| Feature Area |  Non functionals  |
| :----------: | ----------- |
| 📚 Description  | Configure the pipelines (Tekton / Jenkins) with to scan our code for quality analysis |
| ✅ Acceptance Criteria | * Deploy SonarQube using GitOps <br>Setip password as a secret using GitOps <br>Extend the Pipeline with static code analysis </li> </ul>|
| 👕 T-Shirt Size | Medium |

### Task
Install **Sonarqube**, a code quality tool. Edit `ubiquitous-journey/value-tooling.yaml` file, add:

```yaml
  # Sonarqube
  - name: sonarqube
    enabled: true
    source: https://github.com/redhat-cop/helm-charts.git
    source_path: "charts/sonarqube"
    source_ref: "sonarqube-0.0.15"
    values:
      account:
        adminPassword: admin123
        currentAdminPassword: admin
      initContainers: true
      plugins:
        install:
          - https://github.com/checkstyle/sonar-checkstyle/releases/download/8.40/checkstyle-sonar-plugin-8.40.jar
          - https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/2.0.8/sonar-dependency-check-plugin-2.0.8.jar
```

Git add, commit, push your changes:

```bash
cd /projects/tech-exercise
git add .
git commit -m  "⚜️ ADD - sonarqube ⚜️" 
git push 
```

2. Save Sonarqube credentials as SealedSecrets in git repository _(yes, because it is GitOps!)_ and also that pipelines can leverage the secret.

```bash
cat << EOF > /tmp/sonarqube-auth.yaml
apiVersion: v1
data:
  password: "$(echo admin | base64 -w0)"
  username: "$(echo admin123 | base64 -w0)"
kind: Secret
metadata:
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: sonarqube-auth
EOF
```

Use `kubeseal` commandline to seal the secret definition.

```bash
kubeseal < /tmp/sonarqube-auth.yaml > /tmp/sealed-sonarqube-auth.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace do500-shared \
    --controller-name sealed-secrets \
    -o yaml
```

We want to grab the results of this sealing activity, in particular the `encryptedData`.
```bash
cat /tmp/sealed-sonarqube-auth.yaml| grep -E 'username|password'
```

Output would be like:
<pre>
    username: AgAj3JQj+EP23pnzu...
    password: AgAtnYz8U0AqIIaqYrj...
</pre>

Open up `ubiquitous-journey/values-tooling.yaml` file and extend the Sealed Secrets entry. Copy the output of `username` and `password` from the previous command and update the values. Make sure you indent the data correctly.

```yaml
        - name: sonarqube-auth
          type: Opaque
          annotations:
            tekton.dev/git-0: https://gitlab-ce.<CLUSTER_DOMAIN>
          labels:
            credential.sync.jenkins.openshift.io: "true"
          data:
            username: AgAj3JQj+EP23pnzu...
            password: AgAtnYz8U0AqIIaqYrj...
  ```
..and push the changes:

```bash
cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🍳 ADD - sonarqube creds sealed secret 🍳" 
git push
```

Verify that you have the secret definition:
```bash
oc get secrets -n <TEAM_NAME>-ci-cd | grep sonarqube-auth
```

3. Connect to Sonarqube UI to verify if the installation is successfull:
```bash
oc get route sonarqube --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd
```
`TODO` 
- add screenshot

`TODO`
- [ ] Setup a code quality gate e.g. chart here https://github.com/eformat/sonarqube-jobs
```yaml
  # Sonarqube setup
  - name: sonarqube-setup
    enabled: true
    source: https://github.com/eformat/sonarqube-jobs
    source_path: charts/quality-gate
    source_ref: main
    values:
      qualityGate:
        new_coverage:
          enabled: false
```

🐈‍⬛ `Jenkins Group` 🐈‍⬛

- [ ] Configure your pipeline to run code analysis
- [ ] Configure your pipeline to check the quality gate
- [ ] Improve your application code quality
- [jenkins](3-revenge-of-the-automated-testing/1a-jenkins.md)

🐅 `Tekton Group` 🐅

- [ ] Configure your pipeline to run code analysis
- [ ] Configure your pipeline to check the quality gate
- [ ] Improve your application code quality
- [tekton](3-revenge-of-the-automated-testing/1b-tekton.md)