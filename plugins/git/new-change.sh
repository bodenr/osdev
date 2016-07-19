#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=new-change
OSDEV_PLUGIN_USAGE_LINE="new-change <project> <topic> [dependant-id]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[topic]=$'(Required) The topic branch name to use for the change.'
OSDEV_PLUGIN_ARGS[dependant-id]=$'(Optional) The change ID the new topic depends on.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Start a new change for the said <project> on the said <topic> branch.
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

    local _project="${1}.git"
    local _dest=${OSDEV_LONG_TERM_DIR}/${1}-${2}

    clone ${_project} ${_dest}
    pushd ${_dest}

    if [ ${3:-''} != '' ]; then
        git review -d ${3} || (echo "Failed to fetch change: ${3}";exit 1)
    fi

    git checkout -b ${2} || exit 1

    popd

    launch_project ${_dest}

    echo "New change ready for editing in: ${_dest}"
}
