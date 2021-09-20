# Exercise 3 - Revenge of the Automated Testing

> Continuous Testing - End-to-end testing looks good, but is invariably bad because it will never catch all the bugs. What we really need is continuous testing.

Continuous Delivery needs rapid and reliable feedback. Investing in continuous testing is a worthwhile activity.

<!-- ![images/continuous-testing.png](images/continuous-testing.png) -->

## 👨‍🍳 Exercise Intro

**💥 Choose your own adventure 💥**

There are lots of things we can do under the heading of `Quality Gates`, so decide for yourselves what you'd like to do. In your table groups, create a Kanban with each of the exercise titles. Discuss among yourselves the order you'd like to do them in and as mobs / pairs etc take tasks from the list and implement them. At the end of each section, play back to the other group what you've accomplished. Then grab the next priortized item on your list!

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
* Sonar - Add static code analysis to the pipelines
* Testing - Add API and front end tests
* Code Linting - Static code linter and coverage reports for our tests
* Kube Linting - Validate K8S yamls against best practices
* ZAP - OWASP application scanning to check for common attack patterns
* Image Security - Finding vulnerabilities inside the images and hosts with StackRox
* Image Signing - Sign your images with cosign
* Load Testing - Automated load tests in your pipeline
* System Test - test the system before promoting to the next stage
