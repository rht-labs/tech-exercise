<!-- .slide: data-background-image="images/RH_NewBrand_Background.png" -->
### DevOps Culture and Practice <!-- .element: class="course-title" -->
### Tech Exercise IV - Return of the Monitoring <!-- .element: class="title-color" -->

### Observability, Logging & Metrics<!-- .element: class="title-color" -->
TL500 <!-- .element: class="title-color" -->



<div class="r-stack">
<div class="fragment fade-out" data-fragment-index="0" >
  <h2>Open Practice Library</h2>
  <img src="images/opl-complete.png">
</div>
<div class="fragment current-visible" data-fragment-index="0" >
  <h2>📈🪵 Observability 🪵📊</h2>
  <a target="_blank" href="https://openpracticelibrary.com/practice/observability/">
  <img src="images/opl-foundation.png">
  </a>
</div>
</div>



### Tech Exercise IV
[Return of the Monitoring](http://rht-labs.com/StarWarsIntroCreator/#!/AN-PnnCgCljRjZ-cOGBI)



#### What is it?
With software, there are often two competing forces at work: 
* Innovation, which inherently is accompanied by system change
* Running software, which is serving end customers and implies that the system is stable

We can identify two important areas to focus on here:

* To help measure the effectiveness of a team’s development and delivery practices
* To start measuring and monitoring activities that allow the rapid diagnosis of issues



#### Why do we do it?
An observable system can tell us many things:

* how our products are used such that we can understand how to scope features and fixes
* the features and fixes to prioritize next
* what needs to be responded to quickly
* the code we ship is delivering value as we expect or not



#### How do we do it?
Ask questions and gather data to answer them.

_Some example data type_ <!--{.element: style="font-size: smaller; font-weight: 100;"} -->
* **Metrics:** the starting point and a great way to measure overall performance and health. For example how many requests per second are being handled by a given service, how much memory is being used, uptime/downtime etc.
* **Logs:** immutable, time-stamped, human-readable text of each event over time.
* **Event:** a detailed record of something that the system did.
* **Traces:** help to identify the work done at each level, therefore, help us to identify latency along the path and which layer causes a bottleneck or a failure.




### How to decide which data is useful?



#### Service Level Indicators (SLIs)
SLIs are about having meaningful measurements of your service from your user’s perspective. They are closely tied to what the users care about, such as availability, latency, or response time.

So the question is; what does the user care about?



#### Example: Pet Battle
During Impact Mapping, we've identified some actors like _Uploaders, Animal Lovers, or Casual Viewers_. 

Let's take one of them and define how they interact with Pet Battle. 
* **Uploaders want to:** 
    - Access to Pet Battle fast
    - Upload multiple cat photos successfully
    - View their own cat photos on the dashboard 



#### _Uploading Photos Successfully_
From an Uploader perspective here “good” means:
1. Pet Battle is always available
2. Upload button functions
3. Upload happens successfully when right type of file is provided
4. Uploaded photos are displayed on the dashboard

From system’s perspective:
1. Pet Battle is up and running, and responds fast enough
2. There is enough space to upload the photos




#### _Uploading Photos Successfully_
#### _SLIs for Pet Battle_
- Request to access Pet Battle complete successfully
- Proportion of access requests that were served are < 150ms (a time-based measurement)
- Database must always have 20% available space

We defined what to measure to track our users' happiness. Next step is to decide the best place to collect data for it (_which we will do during this tech exercise_).




#### Service Level Objectives (SLOs)
Now that we have SLIs, we can set objectives based on that. SLOs are what sets the bar for customer expectations.

Let’s take an SLI and set a realistic objective.

```
User Journey: Uploading Cat Photos
SLI Type: Availability 
SLI Specification: Request to access Pet Battle complete successfully
SLI Implementations:
  - measured from API metrics.
SLO:
  99% of successfull requests in the past 28 days served are less than 150ms
```

_It is important that SLOs are documentated and iterate over time._




#### Error Budgets
Now that we have SLOs defined for Pet Battle - next step is deciding what to do when we don’t meet with them. We define SLOs as a way to make sure that our services are reliable enough for our endusers. When our measurements show if we are not reliable enough - now what?

Let's discuss what would you do if you don't meet with SLOs?



#### 🧑‍🏫 Learning outcomes 🧑‍💻
As a learner, by the end of this exercise I ...
* can add ServiceMonitor for apps to gather metrics
* can query Prometheus to see metrics
* can create alerts with PrometheusRule
* can install Grafana create dashboards with it
* can create search index in Kibana



##### The Big Picture <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="https://rht-labs.com/tech-exercise/4-return-of-the-monitoring/images/big-picture-monitoring.jpg", class="white-style" -->




## Exercise Instructions




_In this exercise, we will use **Prometheus** to gather Pet Battle metrics and **Grafana** to visualize them_

_We will create **Alerts** to be notified about Pet Battle events (based on SLI/SLO definitions)_

_We will use **Fluentd** to collect logs, **ElasticSearch** to store them and **Kibana** to query the logs_



#### 💥 Tech Exercise 💥
* In mobs / pairs work through your tasks
* If in pairs, continuously playback what you accomplish to the others
* Rotate the `driver` a the end of the section to give everyone a go at getting their hands dirty with code!
* If you finish early, try your hand at the `Here be dragons` section



### 💥 Choose your own adventure 💥 <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-iv/tasks.png", class="black-style" data-background-opacity="1"	 -->



### 💥 Prioritize and Extend your Kanban 💥 <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-iii/team-kanban.png", class="black-style" data-background-opacity="1"	 -->



# Exercise Wrap Up



#### Feedback
* Q&A
* Real World Stories
* Pull Requests Welcome 🦄



#### Some Real World Examples <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-iv/example-who.png", class="black-style" data-background-opacity="1"	 -->



<!-- .slide: data-background-image="images/book-background.jpeg", class="black-style"  data-background-opacity="0.3" -->
### Related & Used Practices
* [Observability](https://openpracticelibrary.com/practice/observability)
* [The Big Picture](https://openpracticelibrary.com/practice/teh-big-picture)
* [GitOps](https://openpracticelibrary.com/practice/gitops)
* [Site Reliability Engineering](https://sre.google/books/)
* [SLOs / SLAs / SLIs](https://openpracticelibrary.com/practice/service-level-indicators/)
