<!-- .slide: data-background-image="images/RH_NewBrand_Background.png" -->
### DevOps Culture and Practice <!-- .element: class="course-title" -->
### Tech Exercise I  - The Manual Menace <!-- .element: class="title-color" -->
### Everything as Code <!-- .element: class="title-color" -->
TL500 <!-- .element: class="title-color" -->



<div class="r-stack">
<div class="fragment fade-out" data-fragment-index="0" >
  <h2>Open Practice Library</h2>
  <img src="images/opl-complete.png">
</div>
<div class="fragment current-visible" data-fragment-index="0" >
  <h2>🔥 Everything as Code 🦄</h2>
  <a target="_blank" href="https://openpracticelibrary.com/practice/test-automation/">
  <img src="images/opl-foundation.png">
  </a>
</div>
</div>



### Tech Exercise I
[The Manual Menace](http://rht-labs.com/StarWarsIntroCreator/#!/AN-PkHf-k0FgxKTTKRcA)



#### What is it?
Everything as Code is the practice of treating all parts of the system as code. This means:
![what-it-is](images/tech-exercise-i/what-it-is.png) <!-- .element: class="image-no-shadow image-full-width" -->
<!--
* Storing configuration along with Source Code in a repository such as git.
* All manual steps are scripted, automated, and checked into a source control management system.
* Storing all the things! From bottom to top - infrastructure, operating systems, build configurations, application properties, deployment configurations, etc.
--->



### Why do we do it?
* **Traceability**: Storing your environment descriptions and structure in a version control system allows you to audit changes made to the system, tracked to the individual who made them.
* **Repeatability**: Moving from one cloud provider to another should be a simple task. Picking a deployment target is like shopping around for the best price that week. By storing all things as code, systems can be recreated in moments on various providers.
* **GitOps**: A single source of truth means that you no longer need tribal knowledge or experts to set up cables or attach hard drives.



### Why do we do it?
* **Phoenix Server**: No more fears of configuration drift. If a server needs to be patched or randomly dies, that's OK. Just create it again from scratch using the stored configuration.
* **Cross-functional Teams**: Writing all things as code improves collaboration between silos in an organization. The development team can contribute to the environment creation or can recreate their own like-for-like environments in a sandbox.
* **De-risking**: Changes can be applied to environments or application deployments and reverted to previous states quickly, thus reducing the risk associated with big upgrades of any kind.



### How do we do it?
1. Select automated tools for provisioning and configuration, such as Ansible, templating, bash, etc.
2. Write installation and configuration sequences as code.
3. Design configuration options as templates.
4. Check source configuration code into a source control repository.
5. Use the automated tools to apply your configurations.



#### 🧑‍🏫 Learning Outcomes 🧑‍💻
As a learner, I can perform the following tasks by the end of this exercise:
* Deploy helm charts manually
* Do everything as code 
* Articulate the benefits gained from GitOps
* Drive tool installations through GitOps
* Deploy the labs accelerator - 🔥🦄
<!--
--->



##### The Big Picture <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="https://rht-labs.com/tech-exercise/1-the-manual-menace/images/big-picture-tools.jpg", class="white-style" -->



## Exercise Instructions



_In this exercise, we use GitOps to set up our working environment._

_We will set up Git projects, create dev, test, and stage projects in OpenShift, and deploy tools like **Jenkins** and **Nexus** and ***ArgoCD*** to enable CI/CD in the next exercise. In order to do that, we’ll utilize a very popular approach: GitOps_



### 💥 Before We Begin 💥
* In your table teams, form a **mob** to complete the exercise. Work **together as a team** to deploy your shared tooling and infrastructure!
* You will want to rotate the `driver` at the end of each exercise section to give everyone a chance to get their hands dirty with code!
* If you finish the exercise early, try your hand at the `🐉Here be dragons🐉 ` section.
* Your facilitator will share links to the instructions, OpenShift Console, CRW, and GitLab server.



#### Please be careful with the commands you run ...
![great-power](https://media.giphy.com/media/MCZ39lz83o5lC/giphy.gif)



#### Seeking Help ...
![flow-chart](images/tech-exercise-i/flow-chart.png)<!-- .element: class="image-no-shadow image-full-width" -->



### 💥 Logging in to OpenShift 💥 <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-i/oc-login.png", class="white-style" data-background-opacity="1"	 -->



### 💥 Setup the instructions site 💥 <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-i/instructions.png", class="black-style" data-background-opacity="1"	 -->



### 🧑‍🤝‍🧑Pairing and Mobbing🧑‍🤝‍🧑
[pairing-and-mobbing](https://rht-labs.com/tech-exercise/slides/content/?name=pair-and-mob-programming)



### 💥 Let's GO 💥



# Exercise Wrap Up



#### Feedback
* Q & A
* Real World Stories
* Pull Requests Welcome 🦄



#### WHO - App of Apps <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-i/example-who.png", class="black-style" data-background-opacity="1"	 -->



<!-- .slide: data-background-image="images/book-background.jpeg", class="black-style"  data-background-opacity="0.3" -->
### Related & Used Practices
- [The Big Picture](https://openpracticelibrary.com/practice/teh-big-picture)
- [Pair Programming](https://openpracticelibrary.com/practice/pair-programming)
- [Mob Programming](https://openpracticelibrary.com/practice/mob-programming)
- [Everything-as-code](https://openpracticelibrary.com/practice/everything-as-code)
- [Automation](https://openpracticelibrary.com/practice/)
- [Containers](https://openpracticelibrary.com/practice/)
- [GitOps](https://openpracticelibrary.com/practice/gitops)
