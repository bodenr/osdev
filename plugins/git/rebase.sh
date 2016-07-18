#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=rebase
OSDEV_PLUGIN_USAGE_LINE="rebase <repo-dir> [branch]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The git repo directory to rebase.'
OSDEV_PLUGIN_ARGS[git-args]=$'(Optional) The branch to pull/rebase from. Defaults to \'master\'.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Rebase the current branch of the said <repo-dir> by pulling
and doing an interactive rebase from the said [branch].
EOM


run() {
    if [[ $# -lt 1 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <repo-dir> specified.'
        return
    fi

    if [ ! -d ${1} ]; then
        PLUGIN_EXIT=2
        PLUGIN_MSG="The <repo-dir> ${1} is not a directory."
        return
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
