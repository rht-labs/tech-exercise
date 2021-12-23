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
  <a target="_blank" href="https://openpracticelibrary.com/practice/test-automation/">
  <img src="images/opl-foundation.png">
  </a>
</div>
</div>



### Tech Exercise IV
[Return of the Monitoring](https://starwarsintrocreator.kassellabs.io/?ref=redirect#!/BL_hsikixFsVbDNyZ28h)



##### The Big Picture <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="https://rht-labs.com/tech-exercise/4-return-of-the-monitoring/images/big-picture-monitoring.jpg", class="white-style" -->



#### 🧑‍🏫 Learning outcomes 🧑‍💻
As a learner, by the end of this exercise I ...
* can add ServiceMonitor for apps to gather metrics
* can query Prometheus to see metrics
* can create alerts with PrometheusRule
* can install Grafana create dashboards with it
* can create search index in Kibana
<!--
--->



#### What is it?
With software, there are often two competing forces at work: 
* Innovation, which inherently is accompanied by system change
* Running software, which is serving end customers and implies that the system is stable

We can identify two important areas to focus on here:

* To help measure the effectiveness of a team’s development and delivery practices
* To start measuring and monitoring activities that allow the rapid diagnosis of issues



#### Why do we do it?
An observable system can tell us many things:

* how users use our products so that we can understand how to scope features and fixes
* what to prioritize next for features and fixes
* what needs to be responded quickly
* the code we ship deliver the value as we expect or not



#### How do we do it?
Ask questions and gather data to answer them.

_Some example data type_ <!--{.element: style="font-size: smaller; font-weight: 100;"} -->
* **Metrics:** the starting point and a great way to measure overall performance and health. For example how many requests per second are being handled by a given service, how much memory is being used, etc.
* **Event:** a detailed record of something that the system did.
* **Logs:** immutable, time-stamped, human-readable text of each event over time.
* **Traces:** helps to identify the work done at each level, therefore, help us to identify latency along the path and which layer causes a bottleneck or a failure.



## Exercise Instructions




_In this exercise, we will use **Prometheus** to gather Pet Battle metrics and **Grafana** to visualize them_

_We will create **Alerts** to be notified about Pet Battle health_

_We will use **ElasticSearch** to collect logs and **Kibana** to query the logs_



#### 💥 90mins of Tech Exercise 💥
* In mobs / pairs work through your tasks
* If in pairs, continuously playback what you accomplish to the others
* Rotate the `driver` a the end of the section to give everyone a go at getting their hands dirty with code!
* If you finish early, try your hand at the `Here be dragons` section


# Exercise Wrap Up



#### Feedback
* Q&A
* Real World Stories
* Pull Requests Welcome 🦄



#### Some Real World Examples <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/tech-exercise-iv/example-who.png", class="black-style" data-background-opacity="1"	 -->



<!-- .slide: data-background-image="images/chef-background.png", class="white-style" -->
### Related & Used Practices
* [Observability](https://openpracticelibrary.com/practice/observability)
* [The Big Picture](https://openpracticelibrary.com/practice/teh-big-picture)
* [GitOps](https://openpracticelibrary.com/practice/gitops)
