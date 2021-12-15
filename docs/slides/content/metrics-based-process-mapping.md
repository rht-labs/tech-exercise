<!-- .slide: data-background-image="images/RH_NewBrand_Background.png" -->
## DevOps Culture and Practice <!-- {.element: class="course-title"} -->
### Metric-Based Process Mapping <!-- {.element: class="title-color"} -->
TL500 <!-- {.element: class="title-color"} -->



### Batch Processing
#### _What is it?_
* Concurrent work being done
* Typically performed on a schedule or specific timeframe

#### _How can it be used?_
* Help identify Work In Progress limits
* Show flow of work through the team/system

#### [The Penny Game](https://www.leanagiletraining.com/better-agile/agile-penny-game-rules/)
1. Break out into teams and experiment with batch processing using poker chips.
2. Follow the facilitator's instructions.



<div class="r-stack">
<div class="fragment fade-out" data-fragment-index="0" >
  <h2>Open Practice Library</h2>
  <img src="images/opl-complete.png">
</div>
<div class="fragment current-visible" data-fragment-index="0" >
  <h2>Metric-Based Process Mapping</h2>
  <a target="_blank" href="https://openpracticelibrary.com/practice/metrics-based-process-mapping/">
  <img src="images/opl-discovery.png">
  </a>
</div>
</div>



### Value Streams 
Each table picks a sector and a business use case (some examples below):
* **Telco** - Ordering a new Broadband package
* **Finance** - Creating new Current Account
* **Government** - Paying for Council Tax
* **Energy** - Switching energy provider
#### Some questions to lead the discussions ...
What is the trigger for the stream?
What is end business value?
What are all the steps in between?
What's the Technology or system that helps with that step?



_DevOps is focused on speeding up that value chain. Metric-Based Process Mapping (MBPM) is a practice that will help visualize all these steps and capture some metrics about how long they take._



### Metric-Based Process Mapping



#### MBPM - Pet Battle <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/mbpm/example-pb.png", class="white-style" -->



#### _What is it?_
* A detailed process mapping practice that captures process steps, responsible actors, and key time and quality metrics.
* Heavily influenced by Karen Martin's work in this area.
* Designed to view the detailed, micro picture and make tactical improvements with front line workers.

![why-use-it](images/mbpm/what-is-it.png)<!-- .element: class="image-no-shadow " -->
<!--
It is a third generation lean process improvement techniques, optimizable for an extended organizational transformation effort.
The first generation comes from Toyota's "information and material flow" as documented in Lean Thinking.
The second generation from Learning to See.
-->



#### _Why use it?_
* Holistically analyze and optimize "brownfield" delivery processes, including everything from requirements definition, infrastructure provisioning and application development.
* Visually represent the way work flows through an organization
* Building a shared understanding throughout the various levels of an organization
how the work is actually done.
* Formulating specific, data driven improvement plans.



### Metrics of Velocity
![accelerate](images/mbpm/accelerate-book.png)<!-- {.element: class="" style="border:none; box-shadow:none; height:200px; float:left;"} -->

* Frequency of deployments (more frequent is better)
* Lead time for new features: from ideation through delivery (shorter is better)
* Frequency of change failures (fewer changes are better)
* Mean-time-to-repair, MTTR (shorter recovery times are better)



![performance-metrics](images/mbpm/performance-metrics.png)<!-- .element: class="image-no-shadow image-full-width " -->



#### Flow Metrics
* **Throughput** — the number of work items finished per unit of time
* **Work in progress (WIP)** — the number of work items started but not finished. The team can use the WIP metric to provide transparency about their progress towards reducing their WIP and improving their flow
* **Cycle Time** — the amount of elapsed time between when a work item starts and when a work item finishes.
* **Work Item Age** — the amount of time between when a work item started and the current time. This applies only to items that are still in progress.



### Metric-Based Process Mapping
How To ...



<div class="r-stack">
  <img class="image-no-shadow image-full-width" data-fragment-index="0" src="images/mbpm/mbpm-swim-lanes.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="1" src="images/mbpm/mbpm-swim-add-time.png.png">
  <img class="fragment image-no-shadow image-full-width" data-fragment-index="2" src="images/mbpm/images/mbpm/mbpm-steps.png">
</div>



#### Label the map and create Swim Lanes
![Map Label](images/mbpm/mbpm-swim-lanes.png)



#### Add time and the activities (the steps) to the map
![Map Label](images/mbpm/mbpm-swim-add-time.png)



#### Some could be in parallel
![Map Label](images/mbpm/mbpm-steps.png)



### Metric-Based Process Mapping
Document all activities (the steps)



#### The Activity
![the activity](images/mbpm/mbpm-activities-0.png)



#### Name the activity and who's involved
![Map Label](images/mbpm/mbpm-activities-1.png)



#### Add the number of people 
![Map Label](images/mbpm/mbpm-activities-2.png)



#### Add the accuracy
![Map Label](images/mbpm/mbpm-activities-3.png)



#### Process Time / Lead Time
![Map Label](images/mbpm/mbpm-activities-4.png)



### Metric-Based Process Mapping
Lead Time vs. Process Time



![Map Label](images/mbpm/pt-lt-1.png)



![Map Label](images/mbpm/pt-lt-2.png)



![Map Label](images/mbpm/pt-lt-3.png)



### Metric-Based Process Mapping
#### Metrics: Time
* Process Time (PT)
  * The time to actually do the work, if one is able to do it uninterrupted
  * Includes when specific to the task at hand:

    Touch, talk, read, and think time
* Lead Time (LT)
  * Elapsed time from the time work is made available until it is completed
  and passed on to the next person or department in the chain
  * Includes process



### Metric-Based Process Mapping
#### Metrics: Quality
* Percent complete and accurate
* Percent of time downstream customer can perform task without having to:
  * **Correct** information or material supplied
  * **Add** information that should have been supplied
  * **Clarify** information that should or could have been clearer



### Metric-Based Process Mapping: How To
#### Define the _Timeline Critical Path_
![Critical Path](images/mbpm/mbpmstep6.png)



### Metric-Based Process Mapping: What Else To Do?
* Create the timeline
* Create summary metrics
* Identify improvement areas




### Exercise - TODO List MBPM (Assumptions)

* Guardrails are:
  * Start - Feature Complete and ready to commit
  * End - Feature deployed to Test env
* Manual handoff and jobs



### Exercise - TODO List MBPM (Setup)

![Swimlanes](images/mbpm/mbpmstep2.png) <!-- {.element: class="inline-image"} -->
* What will you call your MBPM diagram?
* Who/What are your typical functions that do work in your process?



### Exercise - TODO List MBPM

![Metrics](images/mbpm/mbpmstep5.png) <!-- {.element: class="inline-image"} -->
* PT = The time to actually do the work
* LT = Time from when the work is available until it reaches the next step
* % C&A = Percent of time downstream steps can complete without returning



<!-- .slide: data-background-image="images/chef-background.png", class="white-style" -->
### DevOps practices used in this section:
- [Metric-Based Processing Mapping](https://openpracticelibrary.com/practice/vsm-and-mbpm/)
