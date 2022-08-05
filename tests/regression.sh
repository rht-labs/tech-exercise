#!/bin/bash
# -*- coding: UTF-8 -*-

# Regression tests for tech-exercises

scriptDir=$(cd `dirname "$0"`; pwd; cd - 2>&1 >> /dev/null)
runDir=$scriptDir/doc-regression-test-files
cd $scriptDir/doc-regression-test-files
tests=0
failed_tests=0
personal_access_token=

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
CLEAN=
GITSETUP=true
TOPIC=
NUKEFROMORBIT=

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
    cd /projects/tech-exercise && git checkout main
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

perform_admin_logins() {
    oc login -u ${OCP_ADMIN_USER} -p ${OCP_ADMIN_PASSWORD} --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 --insecure-skip-tls-verify #> /dev/null 2>&1
    if [ "$?" != 0 ]; then
        echo -e "${RED}Failed to login to OpenShift${NC}"
        exit 1
    fi
}

gitlab_personal_access_token() {
    if [ ! -z "${personal_access_token}" ]; then return; fi
    gitlabEncodedPassword=$(echo ${GITLAB_PASSWORD} | perl -MURI::Escape -ne 'chomp;print uri_escape($_)')
    # get csrf from login page
    gitlab_basic_auth_string="Basic $(echo -n ${GITLAB_USER}:${gitlabEncodedPassword} | base64)"
    body_header=$(curl -k -L -s -H "Authorization: ${gitlab_basic_auth_string}" -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/sign_in")
    csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    # login
    curl -k -s -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/auth/ldapmain/callback" \
                        --data "username=${GITLAB_USER}&password=${gitlabEncodedPassword}" \
                        --data-urlencode "authenticity_token=${csrf_token}" \
                        > /dev/null
    # generate personal access token form
    body_header=$(curl -k -L -H "Authorization: ${gitlab_basic_auth_string}" -H 'user-agent: curl' -b /tmp/cookies.txt -i "https://${GIT_SERVER}/profile/personal_access_tokens" -s)
    csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    # revoke them all 💀 !!
    revoke=$(echo $body_header | perl -nle 'print join " ", m/personal_access_tokens\/(\d+)/g;')
    if [ ! -z "$revoke" ]; then
        for x in $revoke; do
            echo "💀 Revoking $x ..."
            curl -k -s -o /dev/null -L -b /tmp/cookies.txt -X POST "https://${GIT_SERVER}/profile/personal_access_tokens/$x/revoke" --data-urlencode "authenticity_token=${csrf_token}" --data-urlencode "_method=put"
        done
    fi
    # scrape the personal access token from the response
    body_header=$(curl -k -s -L -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt "https://${GIT_SERVER}/profile/personal_access_tokens" \
                        --data-urlencode "authenticity_token=${csrf_token}" \
                        --data 'personal_access_token[name]='"${GITLAB_USER}"'&personal_access_token[expires_at]=&personal_access_token[scopes][]=api')
    personal_access_token=$(echo $body_header | perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
}

gitlab_setup() {
    echo "🍓 Setting up Gitlab ..."
    gitlab_personal_access_token
    # get or create group id
    group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/groups?search=${TEAM_NAME}" | jq -c '.[] | .id')
    if [ -z "$group_id" ]; then
        group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/groups" --data "name=${TEAM_NAME}&path=${TEAM_NAME}&visibility=public" | jq -c '.id')
    fi
    gitlab_recreate_project "tech-exercise"
}

gitlab_create_argo_webhook() {
    echo "🌶️ Create ArgoCD Gitlab Webhook ..."
    gitlab_personal_access_token
    # get or create webhook
    project_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects?search=${TEAM_NAME}%2Ftech-exercise" | jq -c '.[] | .id')
    if [ ! -z "$project_id" ]; then
        hook_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" | jq -c '.[] | .id')
        if [ -z "$hook_id" ]; then
            argocd_url=https://$(oc get route argocd-server --template='{{ .spec.host }}'/api/webhook -n ${TEAM_NAME}-ci-cd)
            curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" --data "id=1&url=$argocd_url" > /dev/null 2>&1
        fi
    else
        echo -e "${RED}No project ${TEAM_NAME}%2Ftech-exercise found ?, bailing out.${NC}"
        exit 1
    fi
}

gitlab_create_jenkins_webhook() {
    echo "🍅 Create Jenkins Gitlab Webhook ..."
    gitlab_personal_access_token
    # get or create webhook
    project_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects?search=${TEAM_NAME}%2Fpet-battle&sort=asc" | jq -c '.[0] | .id')
    if [ ! -z "$project_id" ]; then
        hook_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" | jq -c '.[] | .id')
        if [ -z "$hook_id" ]; then
            jenkins_url=https://$(oc get route jenkins --template='{{ .spec.host }}'/multibranch-webhook-trigger/invoke%3Ftoken=pet-battle -n ${TEAM_NAME}-ci-cd)
            curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" --data "id=1&url=$jenkins_url" > /dev/null 2>&1
        fi
    else
        echo -e "${RED}No project ${TEAM_NAME}%2Fpet-battle found ?, bailing out.${NC}"
        exit 1
    fi
}

gitlab_create_tekton_webhook() {
    echo "🍎 Create Tekton Gitlab Webhook ..."
    gitlab_personal_access_token
    # get or create webhook
    project_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects?search=${TEAM_NAME}%2Fpet-battle-api" | jq -c '.[] | .id')
    if [ ! -z "$project_id" ]; then
        hook_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" | jq -c '.[] | .id')
        if [ -z "$hook_id" ]; then
            tekton_url=https://webhook-${TEAM_NAME}-ci-cd.${CLUSTER_DOMAIN}
            curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/projects/$project_id/hooks" --data "id=1&url=$tekton_url" > /dev/null 2>&1
        fi
    else
        echo -e "${RED}No project ${TEAM_NAME}%2Fpet-battle-api found ?, bailing out.${NC}"
        exit 1
    fi
}

gitlab_delete_group() {
    group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/groups?search=${TEAM_NAME}" | jq -c '.[] | .id')
    if [ -z "$group_id" ]; then
        echo "⚠️ No group ${TEAM_NAME} found for this user, returning."
        return;
    fi
    ret=1; i=0
    until [ $ret = "202" ]
    do
        ret=$(curl -k -s -o /dev/null -w %{http_code} -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X DELETE "https://${GIT_SERVER}/api/v4/groups/${group_id}")
        echo "🧁 Waiting for 202 response to delete group ${TEAM_NAME}"
        sleep 5
        ((i=i+1))
        if [ $i -gt 5 ]; then
            echo -e "${RED}Failed - ${TEAM_NAME} gitlab could not delete group, check supplied user, $ret, bailing out.${NC}"
            exit 1
        fi
    done
}

gitlab_recreate_project() {
    projectname=${1}
    local i=0
    gitlab_personal_access_token
    # get or create group id
    group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/groups?search=${TEAM_NAME}" | jq -c '.[] | .id')
    if [ -z "$group_id" ]; then
        group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/groups" --data "name=${TEAM_NAME}&path=${TEAM_NAME}&visibility=public" | jq -c '.id')
    fi
    # delete project
    ret=1; i=0
    until [ $ret = "202" -o $ret = "404" ]
    do
        ret=$(curl -k -s -o /dev/null -w %{http_code} -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X DELETE "https://${GIT_SERVER}/api/v4/projects/${TEAM_NAME}%2F${projectname}")
        echo "🧁 Waiting for 202 or 404 response to delete ${projectname}"
        sleep 5
        ((i=i+1))
        if [ $i -gt 5 ]; then
            echo -e "${RED}Failed -${projectname} gitlab could not delete, $ret, bailing out.${NC}"
            exit 1
        fi
    done
    # create project
    ret=1; i=0
    until [ $ret = "201" ]
    do
        ret=$(curl -k -s -o /dev/null -w %{http_code} -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/projects" --data "name=${projectname}&visibility=public&namespace_id=${group_id}")
        echo "🍻 Waiting for 201 response to create ${projectname}"
        sleep 5
        ((i=i+1))
        if [ $i -gt 5 ]; then
            echo -e "${RED}Failed - ${projectname} gitlab could not create, $ret, bailing out.${NC}"
            exit 1
        fi
    done
}

gitlab_delete_project() {
    projectname=${1}
    local i=0
    gitlab_personal_access_token
    # get or create group id
    group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X GET "https://${GIT_SERVER}/api/v4/groups?search=${TEAM_NAME}" | jq -c '.[] | .id')
    if [ -z "$group_id" ]; then
        group_id=$(curl -s -k -L -H "Accept: application/json" -H "PRIVATE-TOKEN: ${personal_access_token}" -X POST "https://${GIT_SERVER}/api/v4/groups" --data "name=${TEAM_NAME}&path=${TEAM_NAME}&visibility=public" | jq -c '.id')
    fi
    # delete project
    ret=1; i=0
    until [ $ret = "202" -o $ret = "404" ]
    do
        ret=$(curl -k -s -o /dev/null -w %{http_code} -k -H "PRIVATE-TOKEN: ${personal_access_token}" -X DELETE "https://${GIT_SERVER}/api/v4/projects/${TEAM_NAME}%2F${projectname}")
        echo "🧁 Waiting for 202 or 404 response to delete ${projectname}"
        sleep 5
        ((i=i+1))
        if [ $i -gt 5 ]; then
            echo -e "${RED}Failed -${projectname} gitlab could not delete, ${ret}, bailing out.${NC}"
            exit 1
        fi
    done
}

remove_pet_battle_code() {
    # so reruns work ok as git recreated each time
    rm -rf /projects/pet-battle
    gitlab_recreate_project "pet-battle"
}

remove_pet_battle_api_code() {
    # so reruns work ok as git recreated each time
    rm -rf /projects/pet-battle-api
    gitlab_recreate_project "pet-battle-api"
}

test_file() {
    local file=$1
    local tags=$2
    local outFile=out-${file%%md}json

    echo
    echo -n "=== 🍹 Testing $file tags: $tags"
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

force_delete_namespace() {
    local namespace=${1}
    echo "Force deleting namespace $namespace ..."
    oc delete namespace $namespace --timeout=10s 2>/dev/null
    oc get namespace $namespace -o json | jq '.spec = {"finalizers":[]}' >/tmp/$namespace.json 2>/dev/null
    curl -k -H "Authorization: Bearer $(oc whoami -t)" -H "Content-Type: application/json" -X PUT --data-binary @/tmp/$namespace.json "https://api.${CLUSTER_DOMAIN##apps.}:6443/api/v1/namespaces/$namespace/finalize" 2>/dev/null
}

# needs to be run as cluster-admin to work properly
cleanup() {
    echo "🍆 Cleaning up ..."
    perform_admin_logins
    local namespace=${TEAM_NAME}-ci-cd
    cnt=0
    # FIXME this while loop needs to timeout
    while [ 0 != $(oc -n $namespace get applications -o name 2>/dev/null | wc -l) ]; do
        ((cnt++))
        helm delete uj argocd --namespace $namespace  2>/dev/null
        oc -n $namespace delete application.argoproj.io bootstrap argocd jenkins allure nexus ubiquitous-journey tekton-pipeline test-app-of-pb test-keycloak test-pet-battle-api test-pet-battle sealed-secrets staging-app-of-pb 2>/dev/null
        sleep 10
        if [ $cnt > 3 ]; then
            oc -n $namespace patch application.argoproj.io/bootstrap application.argoproj.io/ubiquitous-journey application.argoproj.io/jenkins application.argoproj.io/nexus application.argoproj.io/tekton-pipeline application.argoproj.io/test-app-of-pb application.argoproj.io/test-keycloak application.argoproj.io/test-pet-battle-api application.argoproj.io/test-pet-battle application.argoproj.io/sealed-secrets application.argoproj.io/staging-app-of-pb --type='json' -p='[{"op": "remove" , "path": "/metadata/finalizers" }]' 2>/dev/null
            force_delete_namespace "$namespace"
        fi
     done
     namespace=${TEAM_NAME}-dev
     force_delete_namespace "$namespace"
     namespace=${TEAM_NAME}-test
     force_delete_namespace "$namespace"
     namespace=${TEAM_NAME}-stage
     force_delete_namespace "$namespace"
     namespace=${TEAM_NAME}-ci-cd
     force_delete_namespace "$namespace"

     gitlab_delete_project "tech-exercise"
     gitlab_delete_project "pet-battle"
     gitlab_delete_project "pet-battle-api"

     gitlab_delete_group

     echo "🫒 Cleanup Done"
}

wait_for_argocd_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "🍞 Waiting for pod argocd-server ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 15 ]; then
            echo -e "${RED}Failed - argocd-server pod never ready.${NC}"
            exit 1
        fi
    done
}

wait_for_jenkins_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l deploymentconfig=jenkins,name=jenkins -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "🥕 Waiting for pod jenkins ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 120 ]; then
            echo -e "${RED}Failed - jenkins pod never ready.${NC}"
            exit 1
        fi
    done
}

wait_for_nexus_server() {
    local i=0
    until [ $(oc -n ${TEAM_NAME}-ci-cd get pod -l app=sonatype-nexus -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' | grep -c "True") -eq 1 ]
    do
        echo "🥗 Waiting for pod nexus ready condition to be True"
        sleep 10
        ((i=i+1))
        if [ $i -gt 120 ]; then
            echo -e "${RED}Failed - nexus pod never ready.${NC}"
            exit 1
        fi
    done
}

wait_for_pet_battle_api() {
    local i=0
    HOST=https://$(oc -n ${TEAM_NAME}-test get route pet-battle-api --template='{{ .spec.host }}')
    until [ $(curl -k -s -o /dev/null -w %{http_code} ${HOST}) = "200" ]
    do
        echo "🥯 Waiting for 200 response from ${HOST}"
        sleep 10
        HOST=https://$(oc -n ${TEAM_NAME}-test get route pet-battle-api --template='{{ .spec.host }}')
        ((i=i+1))
        if [ $i -gt 400 ]; then
            echo -e "${RED}.Failed - pet-battle-api ${HOST} never ready.${NC}"
            exit 1
        fi
    done
}

wait_for_pet_battle() {
    local i=0
    HOST=https://$(oc -n ${TEAM_NAME}-test get route pet-battle --template='{{ .spec.host }}')
    until [ $(curl -k -s -o /dev/null -w %{http_code} ${HOST}) = "200" ]
    do
        echo "🧅 Waiting for 200 response from ${HOST}"
        sleep 10
        HOST=https://$(oc -n ${TEAM_NAME}-test get route pet-battle --template='{{ .spec.host }}')
        ((i=i+1))
        if [ $i -gt 100 ]; then
            echo -e "${RED}Failed - pet-battle ${HOST} never ready.${NC}"
            exit 1
        fi
    done
}

wait_for_the_manual_menace() {
    # wait for these services before proceeding
    wait_for_argocd_server
    wait_for_nexus_server
    wait_for_jenkins_server
}

wait_for_pet_battle_apps() {
    # wait for these services before proceeding
    wait_for_pet_battle_api
    wait_for_pet_battle
}

setup_tests() {
    local skipgitlab=${1}
    echo -e "
    🍊🍊 Rundoc regression tests 🍊🍊
    =================================
    "

    source_shell
    setup_python
    patch_rundoc
    git_checkout
    perform_logins
    if [[ ! -z "${GITSETUP}" && -z "${skipgitlab}" ]]; then
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

    gitlab_create_argo_webhook
}

test_attack-of-the-pipelines() {
    # 2-attack-of-the-pipelines
    setup_test /projects/tech-exercise/docs/2-attack-of-the-pipelines

    test_file 1-sealed-secrets.md "-T bash#test"
    test_file 2-app-of-apps.md "-T bash#test"
    wait_for_pet_battle_apps
    remove_pet_battle_code
    gitlab_create_jenkins_webhook
    test_file 3a-jenkins.md "-T bash#test"
    remove_pet_battle_api_code
    gitlab_create_tekton_webhook
    test_file 3b-tekton.md "-T bash#test"
}

# 1-the-manual-menace
one() {
    setup_tests
    test_the_manual_menance
}

# 2-attack-of-the-pipelines
two() {
    setup_tests "dont-delete-gitlab"
    wait_for_the_manual_menace
    test_attack-of-the-pipelines
}

onetwo() {
    setup_tests
    test_the_manual_menance
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
usage: $0 [ -c -g -z -t 1|2 ]
Run test suite for markdown code snippets
        -c      clean and delete test environment at end of tests
        -g      dont delete gitlab tech-exercise project (default is to delete gitlab projects for each full run)
        -t      test a topic by chapter e.g. 1 or 2 (leave unset to test all)
        -z      nuke/clean team based stuff from orbit (dont do anything else)
EOF
  exit 1
}

while getopts cgzt: a; do
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
    z)
      NUKEFROMORBIT=true
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
[ -z "$OCP_ADMIN_USER" ] && echo "Warning: must supply OCP_ADMIN_USER in env" && exit 1
[ -z "$OCP_ADMIN_PASSWORD" ] && echo "Warning: must supply OCP_ADMIN_PASSWORD in env" && exit 1

export GITLAB_PAT=${GITLAB_PASSWORD}

# Nuke only
if [ ! -z "${NUKEFROMORBIT}" ]; then
    cleanup
    exit 0
fi

# sanity checks
if [ "${TEAM_NAME}" == "${GITLAB_USER}" ]; then
    echo -e "${RED}🍀 You have the luck of the Irish! so you do.
    The gitlab group api will fail when TEAM_NAME and GITLAB_USER are set the same.
    So to save you future pain we will exit now 🍀${NC}"
    exit 1
fi

# run test suite
case $TOPIC in
    1)
      one
      ;;
    2)
      two
      ;;
    1+2)
      onetwo
      ;;
    *)
      all
      ;;
esac

# done
echo "Tests run: $tests"
echo "Failed tests: $failed_tests"

if [ $failed_tests -ne 0 ]; then
    if [ ! -z "${CLEAN}" ]; then
        cleanup
    fi
    echo -e "${RED}There were failed tests.${NC}"
    exit 1
fi

if [ ! -z "${CLEAN}" ]; then
    cleanup
fi

echo -e "${GREEN}All tests passed.${NC}"
exit 0