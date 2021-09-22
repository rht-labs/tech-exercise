## Extend Jenkins Pipeline with 

1. Add a new Jenkins agent with `zap` command line in it. Open up `ubiquitous-journey/values-tooling.yaml` and under `Jenkins` add `jenkins-agent-zap` to the list.

    ```yaml
            # default names, versions, repo and paths set on the template
            - name: jenkins-agent-npm
            - name: jenkins-agent-mvn
            - name: jenkins-agent-helm
            - name: jenkins-agent-argocd
            - name: jenkins-agent-zap # add this one
    ```

    Push the changes to git repository:

    ```bash
    cd /projects/tech-exercise
    git add ubiquitous-journey/values-tooling.yaml
    git commit -m  "🐝 ADD - Zap Jenkins Agent 🐝"
    git push
    ```

2. Let's run

    ```groovy
            stage('  OWASP Scan') {
                agent { label "jenkins-agent-zap" }
                steps {
                sh '''
                    /zap/zap-baseline.py -r index.html -t http://<some website url> || return_code=$?
                    echo "exit value was  - " $return_code
                ''' }
                post {
                always {
                    // publish html
                    publishHTML target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: '/zap/wrk',
                        reportFiles: 'index.html',
                        reportName: 'OWASP Zed Attack Proxy'
            ] }
            } }
    ```
