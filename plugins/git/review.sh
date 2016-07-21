#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=review
declare -xga OSDEV_PLUGIN_ARGS=(project change_id)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS[dir]="The directory to clone the change into. Defaults to ${OSDEV_SHORT_TERM_DIR}<change-id>"
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Fetch the upstream ${OSDEV_GIT_BASE} <project> change \
(given by <change_id>) in preparation for reviewing it. \
If specified the repo and change will be in <dir>, otherwise \
the default ${OSDEV_SHORT_TERM_DIR}<change_id> will be used. \
If set, OSDEV_PROJECT_LAUNCHER ${OSDEV_PROJECT_LAUNCHER} \
will be used to launch the change directory.
EOM


run() {
    local _project="${ARGS[0]}.git"
    local _dir=${KWARGS[dir]:-${OSDEV_SHORT_TERM_DIR}/${ARGS[1]}}

    clone ${_project} ${_dir}
    pushd ${_dir}

    git review -d ${ARGS[1]} || (echo "Failed to fetch change: ${ARGS[1]}";exit 1)
    popd

    launch_project ${_dir}

    echo "Change ${ARGS[1]} ready for review in: ${_dir}"
}
