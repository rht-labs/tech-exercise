#!/bin/bash

# setup container user
/usr/local/bin/entrypoint.sh

# run the test suite
git clone https://github.com/rht-labs/tech-exercise.git 2>&1
cd tech-exercise && git checkout main && cd tests

# cleanup environment first
./regression.sh -z 2>&1

# run test suite
./regression.sh 2>&1
