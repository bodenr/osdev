#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=review
OSDEV_PLUGIN_USAGE_LINE="review <project> <change-id> [dir]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[change-id]=$'(Required) The gerrit change ID to retrieve for review.'
OSDEV_PLUGIN_ARGS[dir]=$'(Optional) The directory to clone the change into. Defaults to /tmp/<change-id>'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Fetch the upstream ${OSDEV_GIT_BASE} <project>
change (given by <change-id>) in preparation for reviewing it.
If set, OSDEV_PROJECT_LAUNCHER ${OSDEV_PROJECT_LAUNCHER}
will be used to launch the change directory.
EOM


run() {
    if [[ $# -lt 1 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <project> specified.'
        return
    elif [[ $# -lt 2 ]]; then
        PLUGIN_EXIT=1
        PLUGIN_MSG='No <change-id> specified.'
        return
    fi
    local _project="${1}.git"
    local _dir=${3:-${OSDEV_SHORT_TERM_DIR}${2}}

    clone ${_project} ${_dir}
    pushd ${_dir}

    git review -d ${2} || (echo "Failed to fetch change: ${2}";exit 1)
    popd

    launch_project ${_dir}

    echo "Change ready for review in: ${_dir}"
}
