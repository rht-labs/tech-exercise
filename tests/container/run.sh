#!/bin/bash

# source env (we are not a login shell)
source /etc/bashrc

# setup container user
/usr/local/bin/entrypoint.sh

# run the test suite
git clone https://github.com/rht-labs/tech-exercise.git 2>&1
cd tech-exercise && git checkout tests && cd tests

./regression.sh 2>&1
