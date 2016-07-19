#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=rebase
OSDEV_PLUGIN_USAGE_LINE="rebase <dir-or-change> [branch]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[dir-or-change]=$'(Required) The (existing) git repo directory to rebase or an upstream change ID to fetch for rebase.'
OSDEV_PLUGIN_ARGS[branch]=$'(Optional) The branch to pull/rebase from. Defaults to \'master\'.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Rebase the current branch of the said <repo-dir> by pulling
and doing an interactive rebase from the said [branch].
EOM


run() {
    if [[ $# -lt 1 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <dir-or-change> specified.'
        return
    fi

    local _repo=${1}
    if [ ! -d ${1} ]; then
        clone
    fi

    pushd ${1}
    local _branch=`git rev-parse --abbrev-ref HEAD`
    git checkout ${2:-master} && git pull && git checkout ${_branch} && git rebase -i ${2:-master}
    PLUGIN_EXIT=$?
    if [ ${PLUGIN_EXIT} -ne 0 ]; then
        PLUGIN_MSG="'git' returned errors."
    else
        launch_project ${1}
    fi
}
