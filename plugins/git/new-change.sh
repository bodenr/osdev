#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=new-change
declare -xga OSDEV_PLUGIN_ARGS=(project topic)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS[depends_id]=$'The change ID the new topic depends on.'
OSDEV_PLUGIN_KW_ARGS[dir]=$'Local directory to clone the project into.'
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Start a new change for [project] on the new [topic] branch. If specified
the [topic] branch will depend on change ID <depends_id>. The repository
will be created in <dir> if specified, otherwise 'OSDEV_LONG_TERM_DIR'
${OSDEV_LONG_TERM_DIR} is used. If defined, the cloned [project] will
be launched via 'OSDEV_PROJECT_LAUNCHER' ${OSDEV_PROJECT_LAUNCHER}
once cloned.
EOM


run() {
    local _project="${ARGS[0]}.git"
    local _topic="${ARGS[1]}"

    local _dir=${KWARGS[dir]:-${OSDEV_LONG_TERM_DIR}/${ARGS[0]}-${ARGS[1]}}
    clone ${_project} ${_dir}
    pushd ${_dir}

    if [ ${KWARGS[depends_id]:-''} != '' ]; then
        git review -d ${KWARGS[depends_id]} || (echo "Failed to fetch depends change: ${KWARGS[depends_id]}";exit 1)
    fi

    git checkout -b ${_topic} || (echo "Failed to checkout branch: ${_topic}";exit 1)

    popd

    launch_project ${_dir}

    echo "New ${_project} topic ${_topic} ready for editing in: ${_dir}"
}
