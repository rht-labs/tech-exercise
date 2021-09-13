### Extend Jenkins Pipeline with Automated Testing
> Jest something something blah blah blah

1. For the Frontend - we'll use Jest to run our unit tests. The tests are written in the format 
`TODO`

2. They can be executed locally by running `npm run test` in our IDE but let's jump ahead and get them going in our pipeline! To do this, we're going to extend the `Build{}` stage in `Jenkinsfile`. Extend the pipeline where <span style="color:green;" >// 🃏 Jest Testing</span> placeholder is. This needs to be happen before the build.

```groovy
        // 🃏 Jest Testing
        echo '### Running Jest Testing ###'
        sh 'npm run test:ci'
```

4. Our test output can be in xml - this is great for Jenkins as he can read the scores and decide to fail the build or not. Let's add the `junit` report to the Jenkinsfile too. When the tests execute, they also collect code coverages statistics. This is another report we can feed Jenkins with!

`post{}` in a Jenkinsfile allows us to do certain activities after the build finsishes. There are hooks provided by Jenkins such as `always{}`, `success{}` and `failure{}` which provide us an ability to do flow control based on the result of the build. In our case, we `alwasys{}` want to report the test results. Add these `post` steps to the pipeline by the placeholder. 
```groovy
      // 📰 Post steps go here
			post {
				always {
					junit 'junit.xml'
					publishHTML target: [
						allowMissing: true,
						alwaysLinkToLastBuild: false,
						keepAll: false,
						reportDir: 'reports/lcov-report',
						reportFiles: 'index.html',
						reportName: 'Web Code Coverage'
					]
				}
			}
```

<p class="tip">
⛷️ <b>NOTE</b> ⛷️ - If you have completed `Sonar Scanning` step, you can include code coverage result into Sonarqube as well. Open up `/projects/pet-battle/sonar-project.js` file and uncomment below line by removing `//` at the beginning:
</p>

```bash
	//'sonar.javascript.lcov.reportPaths': 'reports/lcov.info',
```

3. Push the changes to the git repository, which also will trigger a new build.

```bash
cd /projects/pet-battle
git add .
git commit -m "🍊 ADD - save test results 🍊"
git push
```

4. On Jenkins we should be able to see the test results (Run the build twice to see the graph. Because it needs more than one data point to create the graph.)
{TODO - IMAGES}

5. The code coverage report should also be visisble too by Opening the `Web Code Coverage` HTML 