[![Markdown Rundoc Testsuite](https://github.com/rht-labs/tech-exercise/actions/workflows/run_tests.yaml/badge.svg)](https://github.com/rht-labs/tech-exercise/actions/workflows/run_tests.yaml)

## Stakater Workshop Exercise

This monorepo holds the content for the Stakater DevSecOps with GitOps Workshop. The structure is roughly as follows:

```
...
├── README.md
├── docs
│   ├── 1-the-manual-menace
│   ├── ...
│   ├── facilitation
│   └── slides
├── quick-starts
│   ├── README.md
│   ├── ...
├── tekton
│   ├── ...
├── ubiquitous-journey
    └── ...
```

whereby

* `docs` - contains the student and teacher guides for the technical exercises as well as the classroom
activities. The `slides/content` are written in markdown and automatically published to the site when pushed to main.
* `ubiquitous-journey` -  contains a lightweight fork of the rht-labs ci/cd stack
* `deployments` - contains the helm chart for openshift deployment

### 🏃‍♀️ Running the docs & slides site locally

To launch the slides, ensure you have NodeJS installed or run it in a NodeJS container if you prefer.

```shell
npm i -g docsify-cli@4.4.3
docsify serve ./docs
```

* Open the browser to http://localhost:3000 to view the tech exercise.
* Open the browser to http://localhost:3000/slides to view the slides.

## 🎃 Contribution

Pull requests welcome 🎃. Please 🙏, review 👀 the [Contribution Guide](./CONTRIBUTING.md) to became a contributor.

Changes approved and pushed to main will automatically be published to the docs site.
