# Automated Testing
> what is it why important

1. For this exercise, we will use a tool called **Allure**, a test repository manager, but first let's create SealedSecrets object for username and password:

```bash
cat << EOF > /tmp/allure-auth.yaml
apiVersion: v1
data:
  password: "$(admin | base64 -w0)"
  username: "$(password | base64 -w0)"
kind: Secret
metadata:
  annotaion:
    tekton.dev/git-0: https://gitlab-ce.${CLUSTER_DOMAIN}
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: allure-auth
EOF
```

Use `kubeseal` commandline to seal the secret definition.

```bash
kubeseal < /tmp/allure-auth.yaml > /tmp/sealed-allure-auth.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace do500-shared \
    --controller-name sealed-secrets \
    -o yaml
```

Grab the `encryptedData`:
```bash
cat /tmp/sealed-allure-auth.yaml| grep -E 'username|password'
```

Output would be like:
<pre>
    username: AgAj3JQj+EP23pnzu...
    password: AgAtnYz8U0AqIIaqYrj...
</pre>

Open up `ubiquitous-journey/values-tooling.yaml` file and extend the Sealed Secrets entry. Copy the output of `username` and `password` from the previous command and update the values. Make sure you indent the data correctly.

```yaml
        - name: allure-auth
          type: Opaque
          annotations:
            tekton.dev/git-0: https://gitlab-ce.<CLUSTER_DOMAIN>
          labels:
            credential.sync.jenkins.openshift.io: "true"
          data:
            username: AgAj3JQj+EP23pnzu...
            password: AgAtnYz8U0AqIIaqYrj...
  ```


2. Install Allure through `ubiquitous-journey/value-tooling.yaml` file, add:

```yaml
  # Allure
  - name: allure
    enabled: true
    source: https://github.com/eformat/allure.git
    source_path: "chart"
    source_ref: "main"
    values:
      security:
       enabled: 1
       secret: allure-auth
```

And push the changes to the repository:
```bash
cd /projects/tech-exercise
git add ubiquitous-journey/value-tooling.yaml
git commit -m  "👩‍🏭 ADD - Allure tooling 👩‍🏭" 
git push 
```

🐈‍⬛ `Jenkins Group` 🐈‍⬛
- do xyz
- ![link-to-exercise](todo...)

🐅 `Tekton Group` 🐅
- do xyz
- ![link-to-exercise](todo...)