#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=amend
declare -xga OSDEV_PLUGIN_ARGS=(change_id project)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS[dir]=$'The directory to clone the change into. Defaults to /tmp/<change-id>'
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Clone the upstream [project] and fetch the said [change-id] atop
it in preparation for amending. If specified, the said <dir> will be
used, otherwise 'OSDEV_LONG_TERM_DIR' ${OSDEV_LONG_TERM_DIR} is used.
If defined, the cloned [project] will be launched via 'OSDEV_PROJECT_LAUNCHER'
${OSDEV_PROJECT_LAUNCHER} once cloned.
EOM


run() {

    local _project="${ARGS[1]}.git"
    local _dir=${KWARGS[dir]:-${OSDEV_LONG_TERM_DIR}/${ARGS[0]}}
    clone ${_project} ${_dir}
    pushd ${_dir}
    git review -d ${ARGS[0]} || (echo "Failed to fetch change: ${ARGS[0]}";exit 1)
    local _branch=`git rev-parse --abbrev-ref HEAD`
    local _commit_branch=`echo ${_branch} | cut -d"/" -f3-`
    git branch -m ${_branch} ${_commit_branch} || exit 1
    popd

    launch_project ${_dir}
    echo "Change ${ARGS[0]} from ${_project} ready to amend in: ${_dir}"
}
