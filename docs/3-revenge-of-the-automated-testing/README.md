# Exercise 3 - Revenge of the Automated Testing

> Continuous Testing - End-to-end testing looks good, but is invariably bad because it will never catch all the bugs. What we really need is continuous testing.

Continuous Delivery needs rapid and reliable feedback. Investing in continuous testing is a worthwhile activity.

## 👨‍🍳 Exercise Intro

**💥 Choose your own adventure 💥**

There are lots of things we can do under the heading of `Quality Gates`, so decide for yourselves what you'd like to do. In your table groups, create a Kanban with each of the exercise titles. Discuss among yourselves the order you'd like to do them in and as mobs / pairs, take tasks from the list and implement them. At the end of each section, play back to the other group what you've accomplished. Then grab the next priortized item on your list!

![team-kanban](images/team-kanban.jpg)

## 🖼️ Big Picture

![big-picture-pipeline-complete](images/big-picture-pipeline-complete.jpg)

## 🔮 Learning Outcomes

- [ ] Can add security gates to pipeline
- [ ] Can add testing gates to pipeline
- [ ] Can add static code analysis gates to pipeline
- [ ] Can add image signing to the pipeline
- [ ] Can add load testing to the pipeline

## 🔨 Tools used in this exercise!

* <span style="color:blue;">[Sonar](https://www.sonarqube.org/)</span> - Add static code analysis to the pipelines
* Testing Tools - <span style="color:blue;">[Jest](https://jestjs.io/)</span>, <span style="color:blue;">[Allure](https://github.com/allure-framework/allure2)</span>, <span style="color:blue;">[RESTassured](https://quarkus.io/guides/getting-started-testing)</span> - Add API and front end tests
* Code Linting - <span style="color:blue;">[npm lint](https://www.npmjs.com/package/lint)</span>, <span style="color:blue;">[checkstyle](https://checkstyle.sourceforge.io)</span> - Static code linter and coverage reports for our tests
* Kube Linting - <span style="color:blue;">[kubelinter](https://github.com/stackrox/kube-linter)</span>- Validate K8S yamls against best practices
* <span style="color:blue;">[ZAP - OWASP](https://owasp.org/www-project-zap)</span> application scanning to check for common attack patterns
* Image Security - <span style="color:blue;">[StackRox](https://www.stackrox.com)</span> - Finding vulnerabilities inside the images and hosts with StackRox
* Image Signing - <span style="color:blue;">[sigstore](https://www.sigstore.dev)</span> - Sign your images with cosign
* Load Testing - <span style="color:blue;">[locust](https://docs.locust.io/en/stable/index.html)</span> - Automated load tests in your pipeline
* System Test - test the system before promoting to the next stage
