#!/bin/bash

# capture en vars, otherwise use default values
TECH_EXERCISE_REPO="${REPO:=https://github.com/rht-labs/tech-exercise.git}"
TECH_EXERCISE_BRANCH="${BRANCH:=main}"

# setup container user
/usr/local/bin/entrypoint.sh

# run the test suite
git clone "${TECH_EXERCISE_REPO}" 2>&1
cd tech-exercise && git checkout "${TECH_EXERCISE_BRANCH} && cd tests

# nuke and exit
if [ ! -z "${NUKE_ONLY}" ]; then
    ./regression.sh -z 2>&1
    exit 0;
fi

# cleanup environment first
./regression.sh -z 2>&1

# run test suite
if [ ! -z "${EXERCISE}" ]; then
    ./regression.sh -t "${EXERCISE}" 2>&1
else
    ./regression.sh 2>&1
fi