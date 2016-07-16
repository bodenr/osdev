#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=help
OSDEV_PLUGIN_USAGE_LINE="help [command]"
OSDEV_PLUGIN_DESCRIPTION="When run without 'command', prints all command's help. When run with 'command' prints the said commands help text."
declare -gxA OSDEV_PLUGIN_ARGS
OSDEV_PLUGIN_ARGS[command]=$'(Optional) The command to print help for.'
OSDEV_PLUGIN_ARGS=${OSDEV_PLUGIN_ARGS}

plugin_help() {
    echo "${OSDEV_PLUGIN_NAME} (v${OSDEV_PLUGIN_VERSION})"
    echo "--------------------------------------------------------"
    echo "Usage:        ${OSDEV_PLUGIN_USAGE_LINE}"
    echo "Description:  ${OSDEV_PLUGIN_DESCRIPTION}"
    echo ""
    echo "Paramenters:"
    for _arg_name in "${!OSDEV_PLUGIN_ARGS[@]}"; do
        if [ ${_arg_name} != 0 ]; then
            echo "  ${_arg_name} -- ${OSDEV_PLUGIN_ARGS[$_arg_name]}"
        fi
    done
    echo "--------------------------------------------------------"
    echo ""
}


run() {
    local command_name=${1:-""}
    if [ "${command_name}" == "" ]; then
        echo ${OSDEV_EXE_USAGE_LINE}
        echo ""
        echo "Installed command plugins:"
        echo ""
        for_plugins_in OSDEV_PLUGIN_NAMES[@] plugin_help
    else
        declare -a _names=(${command_name})
        for_plugins_in _names[@] plugin_help
    fi
}
