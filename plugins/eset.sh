#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=eset
declare -xga OSDEV_PLUGIN_ARGS=(name value)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Sets the OSDEV env variable [name] to [value]. This setting is \
persisted in ${OSDEV_RC_PATH}.

EOM


run() {
    local _val=${ARGS[1]}
    local _name=`echo ${ARGS[0]} | awk '{print toupper($0)}'`
    if [[ ${_name} != 'OSDEV_'* ]]; then
        _name=OSDEV_${_name}
    fi

    rc_set ${_name} ${ARGS[1]}

    echo "${_name} is now set to ${ARGS[1]}"
}
