#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=new-change
OSDEV_PLUGIN_USAGE_LINE="new-change <project> <topic> [git-args]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[topic]=$'(Required) The topic branch name to use for the change.'
OSDEV_PLUGIN_ARGS[git-args]=$'(Optional) Additional arguments to pass onto the git clone command. Defaults to none.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Start a new change for the said <project> on the said <topic> branch.
Additional <git-args> are passed along to the clone command.
EOM


run() {
    if [[ $# -lt 1 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <project> specified.'
        return
    elif [[ $# -lt 2 ]]; then
        PLUGIN_EXIT=2
        PLUGIN_MSG='No <topic> specified.'
        return
    fi

    local _base=${OSDEV_GIT_BASE}
    local _project="${1}.git"
    local _git_args=${3:-''}
    pushd ${OSDEV_CHANGE_DIR}
    git clone ${_base}${_project} ${_git_args}
    pushd ${1}
    git branch ${2} && git checkout ${2}
    PLUGIN_EXIT=$?
    popd
    popd
    if [ ${PLUGIN_EXIT} -ne 0 ]; then
        PLUGIN_MSG="'git branch' returned errors."
        return
    fi

    launch_project ${_dir}
}
