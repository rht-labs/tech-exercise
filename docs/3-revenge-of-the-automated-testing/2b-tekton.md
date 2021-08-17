### Extend Tekton Pipeline with Automated Testing

Install **Allure**, a test repository manager. Edit `ubiquitous-journey/value-tooling.yaml` file, add:

```yaml
  # Allure
  - name: allure
    enabled: true
    source: https://github.com/eformat/allure.git
    source_path: "chart"
    source_ref: "main"
```
