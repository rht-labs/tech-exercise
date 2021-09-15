## Here be dragons!

![oh-look-another-dragon](../images/oh-look-dragons.png)

### Testing Extensions
- Something something TestContainers
- Continuous Test


### Sonar Quality Gates
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

### Continuous Testing

- https://quarkus.io/guides/continuous-testing

<pre>
The following commands are available:
[r] - Re-run all tests
[f] - Re-run failed tests
[b] - Toggle 'broken only' mode, where only failing tests are run (disabled)
[v] - Print failures from the last test run
[p] - Pause tests
[o] - Toggle test output (disabled)
[i] - Toggle instrumentation based reload (disabled)
[l] - Toggle live reload (enabled)
[s] - Force restart
[h] - Display this help
[q] - Quit
</pre>

Run tests.

```bash
mvn quarkus:test
```

Add a new failing test.

```java
    @Test
    @Story("Test me")
    void testMe() {
        Assert.assertFalse(false);
    }
```

![images/quarkus-continuous-test-fail.png](images/quarkus-continuous-test-fail.png)

Switch to **broken only mode** by pressing `b`

![images/quarkus-continuous-test-broken-only.png](images/quarkus-continuous-test-broken-only.png)

Make the test pass.

```java
    @Test
    @Story("Test me")
    void testMe() {
        Assert.assertFalse(true);
    }
```

![images/quarkus-continuous-test-fix.png](images/quarkus-continuous-test-fix.png)

```bash
git add .
git commit -m  "⛑️ ADD - new test ⛑️" 
git push 
```

Allure new test added, test trend shown.

![images/allure-new-test-add.png](images/allure-new-test-add.png)

`TODO`

- [ ] Document the steps
- [ ] Allure Task should this be in repo already?
- [ ] Allure Annotations, Add a new test, Historical test results
- [ ] DevUI: `mvn quarkus:dev` mode - would need mongodb running in image

![images/quarkus-dev-mode.png](images/quarkus-dev-mode.png)