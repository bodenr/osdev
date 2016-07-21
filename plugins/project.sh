#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=project
declare -xga OSDEV_PLUGIN_ARGS=(project_name:__cur__)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Prints the current OSDEV project when run without any parameters. \
If [project_name] is specified, the current OSDEV project will be set to \
the said [project_name].
EOM


run() {
    local _name=${ARGS[0]}
    if [ "${_name}" == "__cur__" ]; then
        echo "${OSDEV_PROJECT:-"OSDEV_PROJECT not set"}"
    else
        rc_set 'OSDEV_PROJECT' ${_name}
    fi
}
