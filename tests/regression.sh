#!/bin/bash
# -*- coding: UTF-8 -*-

# Regression tests for tech-exercises

scriptDir=$(cd `dirname "$0"`; pwd; cd - 2>&1 >> /dev/null)
runDir=$scriptDir/doc-regression-test-files
cd $scriptDir/doc-regression-test-files
tests=0
failed_tests=0

CLEAN=
GENERATE=

verify_zero_exit() {
    if [ "$?" != "0" ]; then
        echo "Exited with non 0, but 0 expected."
        ((failed_tests++))
    fi
}

verify_non_zero_exit() {
    if [ "$?" = "0" ]; then
        echo "Exited with 0, but failure expected."
        ((failed_tests++))
    fi
}

strip_timestamps() {
    local file_path=$1
    sed -ri '/^\s*"time_(start|stop)": [0-9]{10}\.[0-9]*,?$/d' $file_path
}

strip_output() {
    local file_path=$1
    sed -ri '/^\s*"output":.*$/d' $file_path
}

replace_env_vars() {
    local file_path=$1
    sed -i -e "s|<TEAM_NAME>|${TEAM_NAME}|" $file_path
    sed -i -e "s|<CLUSTER_DOMAIN>|${CLUSTER_DOMAIN}|" $file_path
    sed -i -e "s|<GIT_SERVER>|${GIT_SERVER}|" $file_path
}

git_checkout() {
    cd /projects/tech-exercise && git checkout tests
}

setup_python() {
    if [ -d "env" ]; then
        source env/bin/activate
        return
    fi
    pip3 install virtualenv --user
    ~/.local/bin/virtualenv -p python3 env
    source env/bin/activate
    pip install rundoc
}

source_python() {
    source env/bin/activate
}

perform_logins() {
    oc login -u ${OCP_USER} -p ${OCP_PASSWORD} --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 > /dev/null 2>&1
    if [ ! -f "~/.netrc" ]; then
    cat <<EOF > ~/.netrc
    machine ${GIT_SERVER}
       login ${GIT_USER}
       password ${GIT_PASSWORD}
EOF
    fi
}

test_file() {
    local file=$1
    local tags=$2
    local outFile=out-${file%%md}json

    echo
    echo -n "=== Testing $file tags: $tags"
    echo

    ((tests++))
    replace_env_vars $file
    rundoc run -o $runDir/$outFile $tags $file

    # dont compare time or ouput only run command and return code
    strip_timestamps $runDir/$outFile
    strip_output $runDir/$outFile

    diff $runDir/good-${file%%md}json $runDir/$outFile > /dev/null 2>&1
    if [ "$?" != 0 ]; then
        ((failed_tests++))
        echo "Does NOT Match $runDir/good-${file%%md}json"
        echo " -> failed"
    else
        echo "Matches $runDir/good-${file%%md}json"
        echo " -> success"
        rm -f $runDir/$outFile
    fi
}

setup_test() {
    local testDir=$1
    cd $testDir
    ls -L1 *.md
    echo "----------"
    echo
}

cleanup() {
    echo "Cleaning up ..."
    namespace=${TEAM_NAME}-ci-cd
    cnt=0
    while [ 0 != $(oc -n $namespace get applications -o name 2>/dev/null | wc -l) ]; do
        ((cnt++))
        helm delete uj argocd --namespace $namespace  2>/dev/null
        oc -n $namespace delete application.argoproj.io bootstrap argocd jenkins allure nexus ubiquitous-journey 2>/dev/null
        sleep 10
        if [ $cnt > 3 ]; then
            echo "Force deleting namespace $namespace ..."
            oc delete namespace $namespace --timeout=10s 2>/dev/null
            oc -n $namespace patch application.argoproj.io/bootstrap application.argoproj.io/ubiquitous-journey application.argoproj.io/jenkins application.argoproj.io/nexus --type='json' -p='[{"op": "remove" , "path": "/metadata/finalizers" }]' 2>/dev/null
            oc get namespace $namespace -o json | jq '.spec = {"finalizers":[]}' >/tmp/$namespace.json 2>/dev/null
            curl -k -H "Authorization: Bearer $(oc whoami -t)" -H "Content-Type: application/json" -X PUT --data-binary @/tmp/$namespace.json "https://api.${CLUSTER_DOMAIN##apps.}:6443/api/v1/namespaces/$namespace/finalize" 2>/dev/null
        fi
     done
     echo "Cleanup Done"
}

setup_tests() {
    echo "
    Rundoc regression tests
    =======================
    "

    setup_python
    git_checkout
    perform_logins
}

test_the_manual_menance() {
    # 1-the-manual-menace
    setup_test /projects/tech-exercise/docs/1-the-manual-menace

    test_file 1-the-basics.md "-t bash#test -t zsh#test"
    verify_zero_exit

    test_file 2-argocd.md "-T bash#test"
    verify_zero_exit

    test_file 3-ubiquitous-journey.md "-T bash#test"
    verify_zero_exit

    test_file 4-extend-uj.md "-T bash#test"
    verify_zero_exit

    test_file 5-this-is-gitops.md "-T bash#test"
    verify_zero_exit
}

all() {
    setup_tests

    # TESTS
    test_the_manual_menance

    # other tests

    # done
    echo "Tests run: $tests"
    echo "Failed tests: $failed_tests"
    return $failed_tests
}

usage() {
  cat <<EOF 2>&1
usage: $0 [ -c -g ] 
Run test suite for markdown code snippets
        -c      clean and delete test environment at end of tests
        -g      generate output files only (dont run tests)
EOF
  exit 1
}

while getopts cg a; do
  case $a in
    c)
      CLEAN=true
      ;;
    g)
      GENERATE=true
      ;;
    *)
      usage
      ;;
  esac
done

shift `expr $OPTIND - 1`

# Check for EnvVars
[ -z "$TEAM_NAME" ] && echo "Warning: must supply TEAM_NAME in env" && exit 1
[ -z "$CLUSTER_DOMAIN" ] && echo "Warning: must supply CLUSTER_DOMAIN in env" && exit 1
[ -z "$GIT_SERVER" ] && echo "Warning: must supply GIT_SERVER in env" && exit 1
[ -z "$GIT_USER" ] && echo "Warning: must supply GIT_USER in env" && exit 1
[ -z "$GIT_PASSWORD" ] && echo "Warning: must supply GIT_PASSWORD in env" && exit 1
[ -z "$OCP_USER" ] && echo "Warning: must supply OCP_USER in env" && exit 1
[ -z "$OCP_PASSWORD" ] && echo "Warning: must supply OCP_PASSWORD in env" && exit 1

# run test suite
all
if [ $? -ne 0 ]; then
    echo "There were failed tests."
    if [ ! -z ${CLEAN} ]; then
        cleanup
    fi
    exit 1
fi

if [ ! -z ${CLEAN} ]; then
    cleanup
fi

exit 0