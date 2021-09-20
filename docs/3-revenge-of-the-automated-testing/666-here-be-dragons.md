# Here be dragons!

![oh-look-another-dragon](../images/oh-look-dragons.png)

### Testing Extensions

- Something something TestContainers

### Continuous Testing

- https://quarkus.io/guides/continuous-testing

<div class="highlight" style="background: #f7f7f7">
<pre><code class="language-yaml">
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
</code></pre></div>

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

### Sonar Quality Gates

- [ ] Code Exercise to fix up **Security HotSpots** and improve quality.

![images/sonar-pb-api-hotspots.png](images/sonar-pb-api-hotspots.png)

```java
diff --git a/src/main/java/app/petbattle/Cat.java b/src/main/java/app/petbattle/Cat.java
index c9dad23..a5bcbed 100644
--- a/src/main/java/app/petbattle/Cat.java
+++ b/src/main/java/app/petbattle/Cat.java
@@ -85,7 +85,7 @@ public class Cat extends ReactivePanacheMongoEntity {
                     .encodeToString(baos.toByteArray());
             setImage("data:image/jpeg;base64," + encodedString);
         } catch (IOException e) {
-            e.printStackTrace();
+            // do nothing
         }
     }
 
diff --git a/src/main/java/app/petbattle/CatResource.java b/src/main/java/app/petbattle/CatResource.java
index 5b194b5..c9ed55c 100644
--- a/src/main/java/app/petbattle/CatResource.java
+++ b/src/main/java/app/petbattle/CatResource.java
@@ -26,6 +26,7 @@ import javax.ws.rs.core.MediaType;
 import javax.ws.rs.core.Response;
 import java.io.IOException;
 import java.io.InputStream;
+import java.security.SecureRandom;
 import java.time.Duration;
 import java.util.*;
 
@@ -216,7 +217,7 @@ public class CatResource {
             try {
                 InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream(tc);
                 Cat cat = new Cat();
-                cat.setCount(new Random().nextInt(5) + 1);
+                cat.setCount(new SecureRandom().nextInt(5) + 1);
                 cat.setVote(false);
                 byte[] fileContent = new byte[0];
                 fileContent = is.readAllBytes();
@@ -229,7 +230,7 @@ public class CatResource {
                 cat.persistOrUpdate().await().indefinitely();
 
             } catch (IOException e) {
-                e.printStackTrace();
+                // do nothing
             }
         }
     }
```

Git add, commit, push your changes

```bash
cd /projects/pet-battle-api
git add .
git commit -m  "💍 FIX Security HotSpots 💍"
git push 
```

![images/sonar-pb-api-better-quality.png](images/sonar-pb-api-better-quality.png)

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

### Linting Extensions
