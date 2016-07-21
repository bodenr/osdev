#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=eget
declare -xga OSDEV_PLUGIN_ARGS=(name:__all__)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Prints osdev environment variables. If [name] is given the said \
variable's current value is printed. If [name] is not given \
all current OSDEV env variables are printed. When [name] is specified \
it is automatically converted to the form OSDEV_<name>

EOM


run() {
    local _name=${ARGS[0]}
    if [ "${_name}" == "__all__" ]; then
        ( set -o posix ; set ) | grep ^OSDEV_*=* | while read v; do
            if [[ ${v} != OSDEV_PLUGIN*=* ]]; then
                echo ${v}
            fi
        done
    else
        local _var=`echo ${_name} | awk '{print toupper($0)}'`
        if [[ ${_var} != 'OSDEV_'* ]]; then
            _var=OSDEV_${_var}
        fi
        echo ${!_var}
    fi
}
