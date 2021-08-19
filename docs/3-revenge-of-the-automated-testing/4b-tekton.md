### Extend Tekton Pipeline with Code Coverage & Linting Task

> Why are we doing this


Code formatting as part of the maven build lifecycle
- https://code.revelc.net/formatter-maven-plugin/usage.html

```bash
mvn formatter:format
```

Edit a java class file add some TAB/spaces

![images/formatting-code-pb-api.png](images/formatting-code-pb-api-tab.png)

Then rerun the `formatting:format` maven command:

![images/formatting-code-pb-api.png](images/formatting-code-pb-api.png)

Your changes should be removed !


Linting using Checkstyle (`checkstyle.xml`)

- install an IDE extensions for realtime feedback

![images/checkstyle-extension.png](images/checkstyle-extension.png)

- Sonar build and pipeline feedback
- mvn command line


By default we have an overall checkstyle severity of `warning` in our Pet Battle API `checkstyle.xml` config file. This means we don't stop the build when codestyle is not met. So we will only see this on the command line:

```bash
mvn checkstyle:check

[INFO] You have 0 Checkstyle violations.
```

We also use the checkstyle plugin in Sonarqube which reports checkstyle warnings as **Code Smells*.

![images/checkstyle-sonar.png](images/checkstyle-sonar.png)

Let's set an individual severity of **error** in our configuration for the **EmptyCatchBlock** check
- https://checkstyle.sourceforge.io/config_blocks.html#EmptyCatchBlock

```xml
        <module name="EmptyCatchBlock">
            <property name="severity" value="error"/>
            <property name="exceptionVariableName" value="expected"/>
        </module>
```

We can turn on checkstyle debugging by adding `consoleOutput` true to our pom.xml
```xml
                <configuration>
                    <configLocation>checkstyle.xml</configLocation>
                    <consoleOutput>true</consoleOutput>
                </configuration>
```

Edit the `CatResource.java` class file and remove the comment in the catch block making it empty.

![images/codestyle-violation.png](images/codestyle-violation.png)

Now when we run the check we should get a hard error telling us we have an empty code block.

```bash
mvn checkstyle:check
```

![images/checkstyle-error.png](images/checkstyle-error.png)


These types of checks (as well as tests) are included in the Maven lifecycle phase called **verify**
```bash
mvn verify
```
