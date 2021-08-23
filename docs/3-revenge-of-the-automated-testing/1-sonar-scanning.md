# Sonar Scanning
> what is it why important


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

Git add, commit, push your changes

```bash
cd /projects/tech-exercise
git add .
git commit -m  "⚜️ ADD - sonarqube ⚜️" 
git push 
```

`TODO`
- [ ] SealedSecrets for sonar username/password
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