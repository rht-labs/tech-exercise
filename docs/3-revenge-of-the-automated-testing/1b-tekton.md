### Extend Tekton Pipeline with Sonar Scanning

> What are we going to do

Add `code-analysis` step to our pipeline. Edit `maven-pipeline.yaml` file, add this step before the `maven` build step:

```yaml
    # Code Analysis
    - name: code-analysis
      taskRef:
        name: maven
      params:
        - name: WORK_DIRECTORY
          value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
        - name: GOALS
          value:
            - test
            # - org.owasp:dependency-check-maven:check
            - sonar:sonar
        - name: MAVEN_BUILD_OPTS
          value:
            - '-Dsonar.host.url=http://sonarqube-sonarqube:9000'
            - '-Dsonar.userHome=/tmp/sonar'
            - '-Dsonar.login=admin'
            - '-Dsonar.password=admin123'
      runAfter:
        - fetch-app-repository
      workspaces:
        - name: maven-settings
          workspace: maven-settings
        - name: maven-m2
          workspace: maven-m2
        - name: output
          workspace: shared-workspace
```

Browse to Sonarqube URL

![images/sonar-pb-api.png](images/sonar-pb-api.png)

Add the `sonarqube-quality-gate-check.yaml` Task
```bash
curl -sLo /projects/tech-exercise/tekton/templates/tasks/sonarqube-quality-gate-check.yaml https://raw.githubusercontent.com/petbattle/ubiquitous-journey/main/tekton/tasks/sonarqube-quality-gate-check.yaml
```

Add `code-analysis-check` step to our pipeline.

```yaml
    # Code Analysis Check
    - name: analysis-check
      retries: 1
      taskRef:
        name: sonarqube-quality-gate-check
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
      - name: WORK_DIRECTORY
        value: "$(params.APPLICATION_NAME)/$(params.GIT_BRANCH)"
      runAfter:
      - code-analysis
```

![images/sonar-pb-api-code-quality.png](images/sonar-pb-api-code-quality.png)

Code Exercise to fix up **Security HotSpots** and improve quality.

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

![images/sonar-pb-api-better-quality.png](images/sonar-pb-api-better-quality.png)

`TODO`
- [ ] Document the steps
