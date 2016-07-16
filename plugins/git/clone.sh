#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=clone
OSDEV_PLUGIN_USAGE_LINE="clone <project> [git-args]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[git-args]=$'(Optional) Additional arguments to pass onto the git clone command. Defaults to none.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Clone the upstream ${OSDEV_GIT_BASE:-${DEFAULT_GIT_BASE}} <project>
optionally passing along git arugments. If set, OSDEV_PROJECT_LAUNCHER
${OSDEV_PROJECT_LAUNCHER} will be used to launch
the cloned project.
EOM


run() {
    if [[ $# -lt 1 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <project> specified.'
        return
    fi
    local _base=${OSDEV_GIT_BASE:-${DEFAULT_GIT_BASE}}
    local _project="${1}.git"
    local _git_args=${2:-''}
    git clone ${_base}${_project} ${_git_args}
    PLUGIN_EXIT=$?
    if [ ${PLUGIN_EXIT} -ne 0 ]; then
        PLUGIN_MSG="'git clone' returned errors."
    fi

    if [ ${OSDEV_PROJECT_LAUNCHER:-''} != '' ]; then
        ${OSDEV_PROJECT_LAUNCHER} ${1}
    fi
}
