#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=clone
declare -xga OSDEV_PLUGIN_ARGS=(project branch:master)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS[dir]=$'Local directory to clone the project into.'
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Clone [project] from the current 'OSDEV_GIT_BASE' ${OSDEV_GIT_BASE} \
optionally specifying the [branch] to clone (defaulting to ${OSDEV_BRANCH}). \
If specified the [project] will be cloned into the said <dir>, otherwise the \
default 'OSDEV_LONG_TERM_DIR' ${OSDEV_LONG_TERM_DIR} is used. If defined, \
the cloned [project] will be launched via 'OSDEV_PROJECT_LAUNCHER' \
${OSDEV_PROJECT_LAUNCHER} once cloned.

Examples

Clone neutron into /tmp/neutron:
    ${OSDEV_EXE} ${OSDEV_PLUGIN_NAME} --dir /tmp neutron

Clone neutron stable/mitaka branch into ${OSDEV_LONG_TERM_DIR}:
    ${OSDEV_EXE} ${OSDEV_PLUGIN_NAME} neutron stable/mitaka
EOM


run() {
    local _project="${ARGS[0]}.git"
    local _branch="${ARGS[1]:-${OSDEV_BRANCH}}"
    local _dir=${KWARGS[dir]:-${OSDEV_LONG_TERM_DIR}/${ARGS[0]}}
    clone ${_project} ${_dir} ${_branch}

    launch_project ${_dir}
    echo "Cloned ${_project} branch ${_branch} into ${_dir}"
}
