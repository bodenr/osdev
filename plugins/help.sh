#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=help
declare -xga OSDEV_PLUGIN_ARGS=(command:__all__)
declare -xgA OSDEV_PLUGIN_KW_ARGS
#OSDEV_PLUGIN_KW_ARGS[plugin]=$'The plugin/command to print help for.'
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}

read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Prints detailed usage for the specified <command>, or for all plugins if \
<command> is not specified.

Examples

Print detailed usage for all plugins:
    ${OSDEV_EXE} ${OSDEV_PLUGIN_NAME}

Print detailed usage for the clone plugin:
    ${OSDEV_EXE} ${OSDEV_PLUGIN_NAME} clone

EOM


plugin_help() {
    echo "--------------------------------------------------------"
    echo "Plugin:"
    echo "    ${OSDEV_PLUGIN_NAME} (v${OSDEV_PLUGIN_VERSION})"
    echo

    echo "Usage:"
    declare -a _names=(${OSDEV_PLUGIN_NAME})
    echo_current_plugin_usage_line "    ${OSDEV_EXE} "

    echo ""
    echo "Description:"
    echo "    ${OSDEV_PLUGIN_DESCRIPTION}"
    echo ""

    echo "Optional Parameters:"
    for _arg_name in "${!OSDEV_PLUGIN_KW_ARGS[@]}"; do
        if [ ${_arg_name} != 0 ]; then
            echo "    ${_arg_name} -- ${OSDEV_PLUGIN_KW_ARGS[$_arg_name]}"
        fi
    done
    echo "--------------------------------------------------------"
    echo ""
}


run() {
    local _plugin=${ARGS[0]}
    if [ "${_plugin}" == "__all__" ]; then
        echo ${OSDEV_EXE_USAGE_LINE}
        echo ""
        echo "Installed command plugins:"
        echo ""
        for_plugins_in OSDEV_PLUGIN_NAMES[@] plugin_help
    else
        assert_registered_plugin ${_plugin}
        declare -a _names=(${_plugin})
        for_plugins_in _names[@] plugin_help
    fi
}
