## Extend Jenkins Pipeline with Load Testing

1. For load testing, we will use a Python-based open source tool called <span style="color:blue;">[`locust`](https://docs.locust.io/en/stable/index.html)</span>. Locust helps us to write scenario based load testing and fail the pipeline if the results don't match with our expectations (ie if average response time ratio is higher 200ms, the pipeline fails).

    _You can find how to write more complex testing scenarios for your needs in <span style="color:blue;">[Locust documentation](https://docs.locust.io/en/stable/writing-a-locustfile.html)_</span>

    In order to use `locust cli`, we need a Jenkins agent with python3 in it. Open up `tech-exercise/ubiquitous-journey/values-tooling.yaml` and extend jenkins-agent list with the following:

    ```yaml
            - name: jenkins-agent-python
    ```

    You should have a list similar this now:
    <div class="highlight" style="background: #f7f7f7">
    <pre><code class="language-yaml">
            # Jenkins agents for running builds etc
            # default names, versions, repo and paths set on the template
            - name: jenkins-agent-npm
            - name: jenkins-agent-mvn
            - name: jenkins-agent-helm
            - name: jenkins-agent-argocd
            - name: jenkins-agent-python # add this
    </code></pre></div>

    Commit the changes to the Git repository:

    ```bash
    cd /projects/tech-exercise
    git add ubiquitous-journey/values-tooling.yaml
    git commit -m  "🐍 ADD - Python Jenkins Agent 🐍"
    git push
    ```

    <p class="warn">If you get an error like <b>error: failed to push some refs to..</b>, please run <b><i>git pull</i></b>, then push your changes again by running above commands.</p>    

2. We need to create a `locustfile.py` for testing scenario and save it in the application repository.

    Below scenario calls `/home` endpoint and fails the test if:
    - 1% of /cats calls are not 200 (OK)
    - Total average response time to /cats endpoint is more than 200 ms
    - The max response time in 90 percentile is higher than 800 ms

    ```bash
    cat << EOF > /projects/pet-battle/locustfile.py

    import logging
    from locust import HttpUser, task, events

    class getCat(HttpUser):
        @task
        def cat(self):
            self.client.get("/home", verify=False)

    @events.quitting.add_listener
    def _(environment, **kw):
        if environment.stats.total.fail_ratio > 0.01:
            logging.error("Test failed due to failure ratio > 1%")
            environment.process_exit_code = 1
        elif environment.stats.total.avg_response_time > 200:
            logging.error("Test failed due to average response time ratio > 200 ms")
            environment.process_exit_code = 1
        elif environment.stats.total.get_response_time_percentile(0.95) > 800:
            logging.error("Test failed due to 95th percentile response time > 800 ms")
            environment.process_exit_code = 1
        else:
            environment.process_exit_code = 0
    EOF
    ```

3. Create a stage which uses `jenkins-agent-python` agent and triggers the load test. Copy the below code to the placeholder in `/project/pet-battle/Jenkinsfile`:

    ```groovy
            // 🏋🏻‍♀️ LOAD TESTING EXAMPLE GOES HERE
            stage("🏋🏻‍♀️ Load Testing") {
                agent { label "jenkins-agent-python" }
                options {
                   skipDefaultCheckout(true)
                }
                steps {
                    sh '''
                    git clone ${GIT_URL} pet-battle && cd pet-battle
                    git checkout ${BRANCH_NAME}
                    '''
                    dir('pet-battle'){
                    script {
                        sh '''
                        pip3 install locust
                        locust --headless --users 10 --spawn-rate 1 -H https://${APP_NAME}-${DESTINATION_NAMESPACE}.<CLUSTER_DOMAIN> --run-time 1m --loglevel INFO --only-summary
                        '''
                       }
                    }
                }
            }
    ```

    Above command will install locust cli and then start requests of 10 users at the same time for one minute. Then either fail or keep the pipeline going.

    Now that we update the Jenkinsfile, we need to push the changes which also starts the pipeline.

    ```bash
    cd /projects/pet-battle
    git add Jenkinsfile locustfile.py
    git commit -m  "🌀 ADD - load testing stage and locustfile 🌀"
    git push
    ```

    🪄 Obeserve the **pet-battle** pipeline running with the **load testing** stage.

    If the pipeline fails due to the thresh-holds we set, you can always adjust it by updating the `locustfile.py` with higher values.

    ```py
        if environment.stats.total.fail_ratio > 0.01:
            logging.error("Test failed due to failure ratio > 1%")
            environment.process_exit_code = 1
        elif environment.stats.total.avg_response_time > 200:
            logging.error("Test failed due to average response time ratio > 200 ms")
            environment.process_exit_code = 1
        elif environment.stats.total.get_response_time_percentile(0.95) > 800:
            logging.error("Test failed due to 95th percentile response time > 800 ms")
            environment.process_exit_code = 1
    ```
