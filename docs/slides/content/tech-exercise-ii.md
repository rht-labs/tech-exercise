<!-- .slide: data-background-image="images/RH_NewBrand_Background.png" -->
### DevOps Culture and Practice <!-- .element: class="course-title" -->
## Tech Exercise II <!-- .element: class="title-color" -->
TL500 <!-- .element: class="title-color" -->



<div class="r-stack">
<div class="fragment fade-out" data-fragment-index="0" >
  <h2>Open Practice Library</h2>
  <img src="images/opl-complete.png">
</div>
<div class="fragment current-visible" data-fragment-index="0" >
  <h2>🚚 Attack of the Pipelines 📦🔨</h2>
  <a target="_blank" href="https://openpracticelibrary.com/practice/test-automation/">
  <img src="images/opl-foundation.png">
  </a>
</div>
</div>



### Tech Exercise II
[Attack of the Pipelines](https://starwarsintrocreator.kassellabs.io/?ref=redirect#!/BL_hsn7ZNsj3GYepZrzs)



##### The Big Picture <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="https://rht-labs.com/tech-exercise/2-attack-of-the-pipelines/images/big-picture-first-pipeline.jpg", class="white-style" -->



#### 🧑‍🏫 Learning outcomes 🧑‍💻
As a learner, by the end of this exercise I ...
* can manage Application Config via git
* can automatically build / bake / deploy software Jenkins or Tekton
* can store secrets used by my pipeline securely in git
<!--
--->



#### What is a pipeline
![derek](https://miro.medium.com/max/1400/1*OD6N_1evXg9ffzT47oJx-Q.jpeg)<!-- .element: class="image-no-shadow image-full-width" -->



<div class="r-stack">
  <img class="image-no-shadow image-full-width" data-fragment-index="0" src="images/tech-exercise-ii/derek-1.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="1" src="images/tech-exercise-ii/derek-2.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="2" src="images/tech-exercise-ii/derek-3.png">
</div>



<div class="r-stack">
  <img class="image-no-shadow image-full-width" data-fragment-index="0" src="images/tech-exercise-ii/pipeline1.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="1" src="images/tech-exercise-ii/pipeline2.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="2" src="images/tech-exercise-ii/pipeline3.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="3" src="images/tech-exercise-ii/pipeline4.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="4" src="images/tech-exercise-ii/pipeline5.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="5" src="images/tech-exercise-ii/pipeline6.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="6" src="images/tech-exercise-ii/pipeline7.png">
</div>



<div class="r-stack">
  <img class="image-no-shadow image-full-width" data-fragment-index="0" src="images/tech-exercise-ii/deploy1.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="1" src="images/tech-exercise-ii/deploy2.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="2" src="images/tech-exercise-ii/deploy3.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="3" src="images/tech-exercise-ii/deploy4.png">
</div>



_The job of a Pipeline is to prove that your code is **not** ready for production._



## Continuous Integration



### Continuous Integration
Continuous Integration (**CI**) is a development practice where developers integrate code into a shared repository frequently, 
preferably several times a day

These actions are repeated frequently ensuring that the code base can **continuously integrate**



## 
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-ii/ci.jpg", class="white-style" data-background-opacity="1"	 -->



### Continuous Integration
#### _Why do it?_
* Automated testing reduces busy work and improves software quality.
* Small, regular code commits reduce the number of integration problems.
* Rapid feedback loops make it easier for new contributors to get started.
* Shipping of functional software in small increments is more enjoyable than 
waiting for someone to manually test a giant code change.



### Continuous Integration
#### _How do we do it?_
* Developers submit **small and frequent changes** to the source code
* **Automated** build and test steps are run to ensure code works as expected
* Developers are notified if anything fails and developers react quickly to fix
* The tests and build steps are typically run in an automation server (Tekton, Jenkins, GitLab CI/CD, Apache Airflow...)



#### Jenkins Pipeline - Pet Battle
![Jenkins](https://rht-labs.com/tech-exercise/2-attack-of-the-pipelines/images/jenkins-blue-ocean.png) <!-- .element: class="image-no-shadow image-full-width" -->



#### Tekton Pipeline - Pet Battle API
![Tekton](images/tech-exercise-ii/pb-tekton.png) <!-- .element: class="image-no-shadow image-full-width" -->



<!-- .slide: id="continuous-delivery"-->
## Continuous Delivery



### Continuous Delivery
Continuous delivery (**CD**)  is an extension of continuous integration since it automatically deploys all code changes to a testing and/or staging environment after the build stage. 

This delivers our sotfware to the doorway of production



## 
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-ii/cd.jpg", class="white-style" data-background-opacity="1"	 -->



### Continuous Delivery
#### _What is it?_
* A software engineering practice
* Each change can be **potentially** ready for release to production
* Builds upon the **continuous integration** practice
* Consider automating release to a "demo" area
* Typically implemented with an automation server such as Jenkins or Tekton



### Continuous Delivery
#### _Why do it?_
* Automation reduces the manual work required to do a release
* Faster feedback cycles from quality engineers, product owners, and stakeholders
* Produces a happier operations team
* Prepares the way for push button deployments



<!--.slide: id="continuous-deploymen" -->
## Continuous Deployment




### Continuous Deployment
Continuous deployment (**CD**) is a strategy for software releases wherein any code that has been committed which passes the automated testing phase is automatically released into the production environment, making changes that are visible to the software's users



## 
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-ii/cd-squared.jpg", class="white-style" data-background-opacity="1"	 -->



### Continuous Deployment
#### _What is It?_
* Software development practice
* Development team maintains software so that it can be **released to production** at any moment
* Builds upon the practices of **continuous integration** and **continuous delivery**
* Software configuration and deployment orchestration becomes part of the
development team's duty to maintain the software



### Continuous Deployment
#### _Why do it?_
* Team maintains deployable code and configuration over new features
* Fast feedback from end users
* Features can be pushed out after completion
* Enforces best practice of **eveything as code**
* Configuration and deployment orchestration needs to be part of automation
* Enables quick rollbacks and recovery from failures



### Continuous Deployment
#### _How do we do it?_
* Collaborate closely with everyone involved in deployment and delivery of software
to production
* Automate everything as much as possible
* Build "feature toggles" or "dark launches" to allow for quick rollback if needed
* Provide adequate automated monitoring of the application



## Exercise Instructions



_Separating CI from CD we will first deploy Pet Battle and its supporting infra (keycloak) from Git using ArgoCD's App of Apps pattern. With this in place we will create two pipelines, one for the frontend and one for the api. The frontend will use Jenkins and the backend Tekton_



### 🐙 App of Apps 🐙 <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="https://rht-labs.com/tech-exercise/2-attack-of-the-pipelines/images/test-pet-battle-apps.png", class="black-style" data-background-opacity="1"	 -->



### 💥 Mob to Learn 💥
* Ensure you have completed at least the [Extend the UJ](https://rht-labs.com/tech-exercise/#/1-the-manual-menace/4-extend-uj?id=extend-uj-with-a-another-tool-eg-nexus) excersise from Lab 1
* Continue to Mob for the first two parts of this exercise
  * Sealed Secrets - adding secrets to be used by the pipeline with GitOps
  * Application of Applications - sets up the config repo the pipeline will integrate with



### 💥 Pair to build 💥
Split into 2 groups within your team for [The Pipelines](https://rht-labs.com/tech-exercise/#/2-attack-of-the-pipelines/3-the-pipelines) section:

* 🐈‍⬛ Jenkins Group 🐈‍⬛	- will automate the front components of Pet Battle
* 🐅 Tekton Group 🐅 - will automate the backend components of Pet Battle API

Choose your own adventure but both half of the teams must be successful to finish the exercise!



# Exercise Wrap Up



#### Feedback
* Q&A
* Real World Stories
* Pull Requests Welcome 🦄



#### WHO - Pipelines <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-ii/example-who.png", class="black-style" data-background-opacity="1"	 -->



#### WHO - App of Apps <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-ii/example-who.png", class="black-style" data-background-opacity="1"	 -->



### Summary
* **Continuous Integration**: Integrate several changes into a shared repo and rely heavily on testing to make sure that the changes and commits works and have passed all (unit testing / code quality / code conduct).
* **Continuous Delivery**: The goal is to have a working artifact that's ready to be deployed at any time. It relies on testing and automation to make sure that it has passed all functional tests and can be Manually deployed (push button).
* **Continuous Deployment/Release**: One step further now that we are sure that this is ready to deploy to production then we can rely on features toggle, dark launches or other deployment strategy to promote to other critical environments asap using these techniques for the new features/fixes won't risk the operation.



### Summary
![Pipeline](images/cicd/cdcd.png)



<!-- .slide: data-background-image="images/chef-background.png", class="white-style" -->
### Related & Used Practices
- [Pipelines As Code](https://openpracticelibrary.com/practice/)
- [Continuous Integration](https://openpracticelibrary.com/practice/continuous-integration/)
- [Continuous Delivery](https://openpracticelibrary.com/practice/continuous-delivery)
- [Everything as Code](https://openpracticelibrary.com/practice/everything-as-code/)
- [Information Radiators](https://openpracticelibrary.com/practice/visualisation-of-work/)
