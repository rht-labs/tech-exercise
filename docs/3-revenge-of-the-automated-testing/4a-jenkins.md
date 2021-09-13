### Extend Jenkins Pipeline with Code Linting Step
> something something linting


1. JavaScript has many wonderful _quirks_ and because it's not compiled being able to ensure code is written to a specific style is very important. Enter linting the code! In a large software project ensuring consistency across all engineers can be really helpful for support. We can also enfore the rules in the build!

2. Let's add the linter to the pipeline, extend the `stage{ "Build" }` stage with the lint task....
```groovy
      //💅 Lint exercise here
      echo '### Running Jest Testing ###'
      sh 'npm run lint'
```