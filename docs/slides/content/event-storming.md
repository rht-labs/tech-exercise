<!-- .slide: data-background-image="images/RH_NewBrand_Background.png" -->
## DevOps Culture and Practice <!-- {.element: class="course-title"} -->
### Event Storming <!-- {.element: class="title-color"} -->
TL500 <!-- {.element: class="title-color"} -->



<div class="r-stack">
<div class="fragment fade-out" data-fragment-index="0" >
  <h2>Open Practice Library</h2>
  <img src="images/opl-complete.png">
</div>
<div class="fragment current-visible" data-fragment-index="0" >
  <h2>Event Storming</h2>
  <a target="_blank" href="https://openpracticelibrary.com/practice/event-storming/">
  <img src="images/opl-discovery.png">
  </a>
</div>
</div>



##### <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/example-who.png", class="white-style" -->



### Event Storming
#### _What is it?_
_Event Storming is a rapid, interactive approach to business process discovery and design that yields high quality models._

It provides a repeatable, teachable technique for modeling:
  * Event-driven systems
  * Large microservice-based systems



#### The Knowledge Distribution <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/knowledge-distribution.png", class="white-style" -->



#### _What is it?_
At the end of the event storm, you should have:
* A shared understanding of the business process you are building as part of the project, including:
![you-should-have](images/event-storming/you-should-have.png)<!-- .element: class="image-no-shadow " -->
* A physical diagram with the above information, which can be transferred to a digital format
<!-- ### Event Storming
#### _What is it?_
* Who: key business stakeholders and techies
* There will be lots of talking, a fair bit of squabbling, and periodically
some **very** heated debate
* No chairs!
* Expect a tiring but fun day that achieves a great deal from the most basic of tools -->



#### _Where did it come from?_
![Brandolini](images/event-storming/brandolini.jpg) <!-- {.element: class="inline-image" style="max-width:300px;"} -->
It was introduced in a blog by Alberto Brandolini in 2013.
![ubiquitous-language](images/event-storming/es-ubiquitous-language.png) <!-- {.element: class="" style="max-width:450px;"} -->

It's a sort of Domain Driven Design (DDD) Lite – but with more business focus and less of the jargon and complexity.



#### _Why do we use it?_
* Very simple modelling practice that is accessible to all business people
* Engages all stakeholders and removes technical barriers:
  * Non-technical people can actively contribute
  * Builds a shared understanding
  * Fail fast to solve difficult problems
  * Deliver really useful design artifacts



### Event Storming
#### _Artifacts_
* **Big Picture**: quickly build a shared understanding of a problem space
* **Process Diagram**: model business processes
* **Aggregate Modeling**: find the key microservices, operations, and a retrospective
event model
* **UI Modeling**: model the flow of pages in an application



### 
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/vision-to-detail.png", class="black-style" -->



#### Event Storming - How
The Event Storming Key is specific set of coloured stickies...



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-flow.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-events.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-commands-actors.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-readmodel.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-systems-quests.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-policies.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-aggregates.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-extras.png", class="black-style" -->



<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-flow.png", class="black-style" -->



<!-- # complete -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-complete.png", class="black-style" -->



### Class Exercise



#### Context - PetBattle
* The PetBattle team has decided to use event storming to design part of their system. As with all great teams, they started by defining the example they would map out. This is important as it frames the end-to-end journey and stops them from modelling too big a piece of the application.
* Take the deliverable from the _Impact Map_ to and reframe it using the _Friends Notation_ drill down into the system design
![tow-pb](images/event-storming/tow-pb.png)



#### Create the Event Storm for _"THE ONE WHERE Mary Enters the daily tournament and wins a prize"_
![Key](images/event-storming/key.png) <!-- {.element: class="inline-image"} -->

1. Begin with creating the spine of the `Events`
2. Add the information needed to make a decision with the `Commands`, `Users` and `Read Models`
3. Are there any `policies` or `procedures` that you can identify?
4. Are there new `Systems` (external?) or `Aggregates`?
- <!-- {.element: class="display:none"} -->

#### Things help steer you ...
* Who is Mary? Does she need to need to authenticate to enter the compentition?
* What is the daily prize? How does Mary know about it?
* How will Mary know she's won the competition? Does she get notified? Is there a leaderboard?



### Exercise Wrap Up



##### Pet Battle - No Systems or Policies<!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-pb-no-systems.jpg", class="white-style" -->



##### <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/example-who.png", class="white-style" -->



##### <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/example-who-systems.png", class="white-style" -->



##### <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-emerging-arch.png", class="white-style" -->



##### <!-- .element: class="title-bottom-left" -->
<!-- .slide: data-background-size="contain" data-background-image="images/event-storming/es-emerging-arch3.png", class="white-style" -->



### Event Storming: Key Takeaways
* Builds a shared understanding of a problem space
* Models business processes
* Aggregate modeling to find key microservices and event model
* Models the flow of pages in an application
* Aligns stakeholders and IT groups




#### _Tips for Success_
* Invite the right people: business stakeholders, IT, and User Experience (UX)
* Provide unlimited modeling space with a surface, markers, and stickies
* Keep people refreshed and hydrated! (🥝 🍫 🍌 / 🚰 / 🫖 ☕️)
* Frame the discussion to limit the off topic conversation using TOWs
* If remote, use breakout sessions to encourage more conversation with regular regrouping
![es-tips](images/event-storming/es-tips.png) <!-- {.element: class="image-no-shadow"} -->
* Set up the environment with a Social Contract to ensure psychological safety
* Watch out for the Dungeon Master ...



<!-- .slide: data-background-image="images/chef-background.png", class="white-style" -->
### Related Practices
 * Value Slice: The "commands" naturally become user stories as they're often initiated by a "user". These can be brought into the value slicing process to build the product Backlog
* Impact Map - can form an input for the scope of the modelling
<br>

There are other practices in the space of  working on how we might start building a solution that fixes problems or realize some new opportunities:
* Emerging Architecture
* Non Functional Map
* Metrics-Based Process Map

Together with Event Storm they provide input for creating the Product Backlog.
