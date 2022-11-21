## Extend Tekton Pipeline with Load Testing

1. For load testing, we will use a Python-based open source tool called <span style="color:blue;">[`locust`](https://docs.locust.io/en/stable/index.html)</span>. Locust helps us to write scenario based load testing and fail the pipeline if the results don't match with our expectations (ie if average response time ratio is higher 200ms, the pipeline fails).

    We need to create a `locustfile.py` for testing scenario and save it in the application repository.

    _You can find how to write more complex testing scenarios for your needs in <span style="color:blue;">[Locust documentation](https://docs.locust.io/en/stable/writing-a-locustfile.html)_</span>

    Below scenario calls `/cats` endpoint and fails the test if:
    - 1% of calls are not 200 (OK)
    - Total average response time to `/cats` endpoint is more than 200 ms
    - The max response time in 90 percentile is higher than 800 ms

    ```bash
    cat << EOF > /projects/pet-battle-api/locustfile.py

    import logging
    from locust import HttpUser, task, events

    class getCat(HttpUser):
        @task
        def cat(self):
            self.client.get("/cats", verify=False)

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

2. Add a task to the tekton pipeline for running the load testing:

    ```bash
    cd /projects/tech-exercise
    cat <<'EOF' > tekton/templates/tasks/load-testing.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Task
    metadata:
      name: load-testing
    spec:
      workspaces:
        - name: output
      params:
        - name: APPLICATION_NAME
          description: Name of the application
          type: string
        - name: TEAM_NAME
          description: Name of the team that doing this exercise :)
          type: string
        - name: WORK_DIRECTORY
          description: Directory to start build in (handle multiple branches)
          type: string
      steps:
        - name: load-testing
          image: quay.io/centos7/python-38-centos7:latest
          workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
          script: |
            #!/usr/bin/env bash
            pip3 install locust
            locust --headless --users 10 --spawn-rate 1 -H https://$(params.APPLICATION_NAME)-$(params.TEAM_NAME)-test.{{ .Values.cluster_domain }} --run-time 1m --loglevel INFO --only-summary 
    EOF
    ```

3. Let's add this task into pipeline. Edit `tekton/templates/pipelines/maven-pipeline.yaml` and copy below yaml where the placeholder is.

    ```yaml
        # Load Testing
        - name: load-testing
          runAfter:
            - verify-deployment
          taskRef:
            name: load-testing
          workspaces:
            - name: output
              workspace: shared-workspace
          params:
            - name: APPLICATION_NAME
              value: "$(params.APPLICATION_NAME)"
            - name: TEAM_NAME
              value: "$(params.TEAM_NAME)"
            - name: WORK_DIRECTORY
              value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
    ```

4. Remember -  if it's not in git, it's not real.

    ```bash
    cd /projects/tech-exercise/tekton
    git add .
    git commit -m  "🌀 ADD - load testing task 🌀"
    git push
    ```

5. Now let's trigger the pet-battle-api pipeline by pushing `locustfile.py` and verify if the load testing task works as expected.

    ```bash
    cd /projects/pet-battle-api
    git add locustfile.py
    git commit -m  "🌀 ADD - locustfile for load testing 🌀"
    git push
    ```

    🪄 Observe the **pet-battle-api** pipeline running with the **load-testing** task.

    If the pipeline fails due to the tresholds we set, you can always adjust it by updating the `locustfile.py` with higher values.

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
