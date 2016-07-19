#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=clone
OSDEV_PLUGIN_USAGE_LINE="clone <project> [dir] [branch-or-tag]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[dir]=$'(Optional) Directory to clone the project into.'
OSDEV_PLUGIN_ARGS[branch-or-tag]=$'(Optional) The git branch or tag to checkout.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Clone the upstream ${OSDEV_GIT_BASE} <project>
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

    local _project="${1}.git"
    local _dest=${2:-./${1}}
    clone ${_project} ${_dest} ${3:-master}

    launch_project ${_dest}
}
