#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=amend
OSDEV_PLUGIN_USAGE_LINE="amend <project> <change-id> [dir]"
declare -xgA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[project]=$'(Required) The github project name to checkout. For example \'neutron\'.'
OSDEV_PLUGIN_ARGS[change-id]=$'(Required) The gerrit change ID to retrieve for amending.'
OSDEV_PLUGIN_ARGS[dir]=$'(Optional) The directory to clone the change into. Defaults to /tmp/<change-id>'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Fetch the upstream ${OSDEV_GIT_BASE} <project>
change (given by <change-id>) in preparation for amending it.
The topic branch will be set to the same topic name used in the
fetched change. If set, OSDEV_PROJECT_LAUNCHER ${OSDEV_PROJECT_LAUNCHER}
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
    local _chg_id=${2}
    local _dest=${3:-${OSDEV_LONG_TERM_DIR}/${_chg_id}}
    clone ${_project} ${_dest}
    pushd ${_dest}
    git review -d ${_chg_id} || exit 1
    local _branch=`git rev-parse --abbrev-ref HEAD`
    local _commit_branch=`echo ${_branch} | cut -d"/" -f3-`
    git branch -m ${_branch} ${_commit_branch} || exit 1
    popd

    launch_project ${_dest}
}
