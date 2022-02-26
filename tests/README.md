## 🧪 Testing all the things 🧪

### Markdown code tests

Testing our markdown code snippets using the awesome [rundoc](https://gitlab.com/nul.one/rundoc) tool.

`rundoc` allows you to run your markdown files as if they were scripts. Every code snippet with code highlighting tag is run with interpreter defined by the tag.

We check the command and success return codes (we filter output for now) against `good` run files so we can pick up and regression with the code snippets.

Requirements:
- a running openshift cluster with tl500 tooling installed to run against

Example test run using the tl500 stack container:

```bash
podman pull quay.io/rht-labs/stack-tl500:3.0.10
podman run -d --name stack quay.io/rht-labs/stack-tl500:3.0.10 zsh -c 'sleep infinity'
podman exec -it stack zsh

git clone https://github.com/rht-labs/tech-exercise.git
# FIXME test branch for now 
cd tech-exercise && git checkout tests && cd tests

# Run the test suite
./regression.sh
```

**_FIXME - All the fiddly bits that need more work_**

- [ ] - patch for upto 4 whitespace in markdown -> html

```bash
cat <<'EOF' > rundoc-patch
--- doc-regression-test-files/env/lib/python3.10/site-packages/markdown_rundoc/rundoc_code.py.orig	2022-02-25 11:48:20.325903565 +1000
+++ doc-regression-test-files/env/lib/python3.9/site-packages/markdown_rundoc/rundoc_code.py	2022-02-25 11:48:30.478893321 +1000
@@ -89,7 +89,7 @@
 
 class RundocBlockPreprocessor(Preprocessor):
     RUNDOC_BLOCK_RE = re.compile(r'''
-(?P<fence>^(?:~{3,}|`{3,}))[ ]*         # Opening ``` or ~~~
+(?P<fence>^\s{0,4}(?:~{3,}|`{3,}))[ ]*         # Opening ``` or ~~~
 (\{?\.?(?P<tags>[^\n\r]*))?[ ]*         # Optional {, and lang
 # Optional highlight lines, single- or double-quote-delimited
 (hl_lines=(?P<quot>"|')(?P<hl_lines>.*?)(?P=quot))?[ ]*
EOF
```

- [ ] may need to remove bash#test tags etc in html redraw
- [ ] secrets and env vars in rundoc (which has some support?)
- [X] `oc login` manual for now
- [ ] regression.sh can generate output files
- [ ] gitlab create team and public repos first
- [ ] gitlab adding webhooks
- [X] gitlab creds first time we commit / cache
- [X] gitlab secret manual for now

```bash
echo export GITLAB_USER=user | tee -a ~/.bashrc -a ~/.zshrc
echo export GITLAB_PASSWORD=password | tee -a ~/.bashrc -a ~/.zshrc
```

- [ ] remove branch for tests development uj

```bash
--set source_ref=tests
```

- [X] add a tidy function to delete all ocp resources at end of tests
- [ ] add a tidy function to delete all git resources at end of tests

- [ ] waits on resources .. e.g for nexus, jenkins pods - ho do we sync this ? hardcode between tests ?
