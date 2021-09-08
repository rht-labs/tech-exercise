### Extend Jenkins Pipeline with Sonar Scanning

1. Create a sonar file in the root of the project. This file contains the information of Sonarqube instance.

```bash
cd /projects/pet-battle
cat << EOF > sonar-project.js
const scanner = require('sonarqube-scanner');

scanner(
  {
    serverUrl: 'http://sonarqube-sonarqube:9000',
    options: {
      'sonar.login': process.env.SONAR_USERNAME,
      'sonar.password': process.env.SONAR_PASSWORD,
      'sonar.projectName': 'Pet Battle',
      'sonar.projectDescription': 'Pet Battle UI',
      'sonar.sources': 'src',
      'sonar.tests': 'src',
      'sonar.inclusions': '**', // Entry point of your code
      'sonar.test.inclusions': 'src/**/*.spec.js,src/**/*.spec.ts,src/**/*.spec.jsx,src/**/*.test.js,src/**/*.test.jsx',
      'sonar.exclusions': '**/node_modules/**',
      //'sonar.test.exclusions': 'src/app/core/*.spec.ts',
      'sonar.javascript.lcov.reportPaths': 'reports/lcov.info',
      'sonar.testExecutionReportPaths': 'coverage/test-reporter.xml'
    }
  },
  () => process.exit()
);
EOF
```

2. Then we need to introduce SonarQube credentials to Jenkinsfile. Add the followings to the beginning of the file in `environment` block.

```groovy
		SONARQUBE_CREDS = credentials("${OPENSHIFT_BUILD_NAMESPACE}-sonarqube-auth")
```
You'll have:

<pre>
		<span style="color:green;" >// Credentials bound in OpenShift</span>
		GIT_CREDS = credentials(<span style="color:orange;" >"</span>${OPENSHIFT_BUILD_NAMESPACE}<span style="color:orange;" >-git-auth"</span>)
		NEXUS_CREDS = credentials(<span style="color:orange;" >"</span>${OPENSHIFT_BUILD_NAMESPACE}<span style="color:orange;" >-nexus-password"</span>)
		SONAR_CREDS = credentials(<span style="color:orange;" >"</span>${OPENSHIFT_BUILD_NAMESPACE}<span style="color:orange;" >-sonar-auth"</span>)
</pre>

And add a stage in to the pipeline where <span style="color:green;" >// SONARQUBE SCANNING</span> placeholder is. This needs to be happen before the build.

```groovy
        // 🌞 SONARQUBE SCANNING EXERCISE GOES HERE 
		stage("🌞 Sonar Scanning") {
			agent { label "jenkins-agent-npm" }
      when {
				expression { GIT_BRANCH.startsWith("master") || GIT_BRANCH.startsWith("main") }
			}
			steps {
				script {
            sh '''
					    export SONAR_USERNAME = ${SONARQUBE_CREDS_USR}
					    export SONAR_PASSWORD = ${SONARQUBE_CREDS_PSW}
					  	npm run sonar
            '''
				}
			}
		}
```

3. Push the changes to the git repository, which also will trigger a new build.

```bash
cd /projects/pet-battle
git add Jenkinsfile sonar-project.js
git commit -m "🧦 test code-analysis step 🧦"
git push
```

4. Observe the pipeline and when Sonar Scanning stage is completed, browse the Sonarqube UI to see the details.

** Update the screenshots **
![images/sonar-pb-api.png](images/sonar-pb-api.png)