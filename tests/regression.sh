#!/bin/bash
# -*- coding: UTF-8 -*-

# Regression tests for tech-exercises

scriptDir=$(cd `dirname "$0"`; pwd; cd - 2>&1 >> /dev/null)
runDir=$scriptDir/doc-regression-test-files
cd $scriptDir/doc-regression-test-files
tests=0
failed_tests=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
CLEAN=
GITSETUP=true
TOPIC=

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

sanitize_env_vars() {
    local file_path=$1
    sed -i -e "s|${TEAM_NAME}|<TEAM_NAME>|" $file_path
    sed -i -e "s|${CLUSTER_DOMAIN}|<CLUSTER_DOMAIN>|" $file_path
    sed -i -e "s|${GIT_SERVER}|<GIT_SERVER>|" $file_path
}

git_checkout() {
    cd /projects/tech-exercise && git checkout tests
}

source_shell() {
    # source env (we are not a login shell)
    source /etc/bashrc
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

patch_rundoc() {
    # cater for upto 4 spaces at start of code block in markdown
    sed -i -e "s|P<fence>^(|P<fence>^\\\s{0,4}(|" /projects/tech-exercise/tests/doc-regression-test-files/env/lib/python3.9/site-packages/markdown_rundoc/rundoc_code.py
}

perform_logins() {
    oc login -u ${OCP_USER} -p ${OCP_PASSWORD} --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 --insecure-skip-tls-verify #> /dev/null 2>&1
    if [ "$?" != 0 ]; then
        echo -e "${RED}Failed to login to OpenShift${NC}"
        exit 1
    fi
    if [ ! -f "~/.netrc" ]; then
    cat <<EOF > ~/.netrc
    machine ${GIT_SERVER}
       login ${GITLAB_USER}
       password ${GITLAB_PASSWORD}
EOF
    fi
}

gitlab_setup() {
    echo "Setting up Gitlab ..."
    # get csrf from login page
    gitlab_basic_auth_string="Basic $(echo -n ${GITLAB_USER}:${GITLAB_PASSWORD} | base64)"
    body_header=$(curl -L -s -H "Authorization: ${gitlab_basic_auth_string}" -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/sign_in")
    csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    # login
    curl -s -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/auth/ldapmain/callback" \
                        --data "username=${GITLAB_USER}&password=${GITLAB_PASSWORD}" \
                        --data-urlencode "authenticity_token=${csrf_token}" \
                        > /dev/null
    # generate personal access token form
    body_header=$(curl -L -H "Authorization: ${gitlab_basic_auth_string}" -H 'user-agent: curl' -b /tmp/cookies.txt -i "https://${GIT_SERVER}/profile/personal_access_tokens" -s)
    csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    # ccrape the personal access token from the response
    body_header=$(curl -s -L -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt "https://${GIT_SERVER}/profile/personal_access_tokens" \
                        --data-urlencode "authenticity_token=${csrf_token}" \
                        --data 'personal_access_token[name]='"${GITLAB_USER}"'&personal_access_token[expires_at]=&personal_access_token[scopes][]=api')
    personal_access_token=$(echo $body_header | perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    # get or create group id
    group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/groups?search=${TEAM_NAME}" | jq -c '.[] | .id')
    if [ -z $group_id ]; then
        group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/groups" --data "name=${TEAM_NAME}&path=${TEAM_NAME}&visibility=public" | jq -c '.id')
    fi
    # delete team project
    curl -s -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X DELETE "https://${GIT_SERVER}/api/v4/projects/${TEAM_NAME}%2Ftech-exercise" >/dev/null 2>&1
    # create project
    curl -s -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/projects" --data "name=tech-exercise&visibility=public&namespace_id=${group_id}" > /dev/null 2>&1
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
    sanitize_env_vars $runDir/$outFile

    diff $runDir/good-${file%%md}json $runDir/$outFile > /dev/null 2>&1
    if [ "$?" != 0 ]; then
        ((failed_tests++))
        echo -e "${RED}Does NOT Match $runDir/good-${file%%md}json${NC}"
        echo -e "${RED} -> failed${NC}"
        echo
        diff -u $runDir/good-${file%%md}json $runDir/$outFile
    else
        echo -e "${GREEN}Matches $runDir/good-${file%%md}json${NC}"
        echo -e "${GREEN} -> success${NC}"
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

    source_shell
    setup_python
    patch_rundoc
    git_checkout
    perform_logins
    if [ ! -z ${GITSETUP} ]; then
        gitlab_setup
    fi
}

test_the_manual_menance() {
    # 1-the-manual-menace
    setup_test /projects/tech-exercise/docs/1-the-manual-menace

    test_file 1-the-basics.md "-t bash#test -t zsh#test"
    test_file 2-argocd.md "-T bash#test"
    test_file 3-ubiquitous-journey.md "-T bash#test"
    test_file 4-extend-uj.md "-T bash#test"
    test_file 5-this-is-gitops.md "-T bash#test"
}

wait_for_argocd_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "Waiting for pod argocd-server ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 15 ]; then
            echo "Failed - argocd-server pod never ready"
            exit 1
        fi
    done
}

wait_for_jenkins_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l deploymentconfig=jenkins,name=jenkins -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "Waiting for pod jenkins ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 120 ]; then
            echo "Failed - jenkins pod never ready"
            exit 1
        fi
    done
}

wait_for_nexus_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l app=sonatype-nexus -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "Waiting for pod nexus ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 30 ]; then
            echo "Failed - nexus pod never ready"
            exit 1
        fi
    done
}

wait_for_the_manual_menace() {
    # wait for these sevices before proceeding
    wait_for_argocd_server
    wait_for_nexus_server
    wait_for_jenkins_server
}

test_attack-of-the-pipelines() {
    # 2-attack-of-the-pipelines
    setup_test /projects/tech-exercise/docs/2-attack-of-the-pipelines

    test_file 1-sealed-secrets.md "-T bash#test"

}

# 1-the-manual-menace
one() {
    setup_tests
    test_the_manual_menance
}

# 2-attack-of-the-pipelines
two() {
    setup_tests
    wait_for_the_manual_menace
    test_attack-of-the-pipelines
}

# all tests
all() {
    setup_tests
    test_the_manual_menance
    wait_for_the_manual_menace
    test_attack-of-the-pipelines
}

usage() {
  cat <<EOF 2>&1
usage: $0 [ -c -g -t 1|2 ]
Run test suite for markdown code snippets
        -c      clean and delete test environment at end of tests
        -g      dont delete gitlab projects (default is true delete each run)
        -t      test a topic by chapter e.g. 1 or 2 (leave unset to test all)
EOF
  exit 1
}

while getopts cgt: a; do
  case $a in
    c)
      CLEAN=true
      ;;
    g)
      GITSETUP=
      ;;
    t)
      TOPIC=$OPTARG
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
[ -z "$GITLAB_USER" ] && echo "Warning: must supply GITLAB_USER in env" && exit 1
[ -z "$GITLAB_PASSWORD" ] && echo "Warning: must supply GITLAB_PASSWORD in env" && exit 1
[ -z "$OCP_USER" ] && echo "Warning: must supply OCP_USER in env" && exit 1
[ -z "$OCP_PASSWORD" ] && echo "Warning: must supply OCP_PASSWORD in env" && exit 1

# run test suite
case $TOPIC in
    1)
      one
      ;;
    2)
      two
      ;;
    *)
      all
      ;;
esac

# done
echo "Tests run: $tests"
echo "Failed tests: $failed_tests"

if [ $failed_tests -ne 0 ]; then
    if [ ! -z ${CLEAN} ]; then
        cleanup
    fi
    echo "There were failed tests."
    exit 1
fi

if [ ! -z ${CLEAN} ]; then
    cleanup
fi

echo "All tests passed."
exit 0