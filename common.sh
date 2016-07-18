#!/usr/bin/env bash


declare -Ag OSDEV_PLUGINS
OSDEV_PLUGIN_NAMES=()
_PLUGIN_VARS=(OSDEV_PLUGIN_VERSION OSDEV_PLUGIN_NAME OSDEV_PLUGIN_USAGE_LINE OSDEV_PLUGIN_DESCRIPTION OSDEV_PLUGIN_ARGS)
DEFAULT_GIT_BASE='https://github.com/openstack/'
OSDEV_GIT_BASE=${OSDEV_GIT_BASE:-${DEFAULT_GIT_BASE}}
OSDEV_TMP_DIR=/tmp
OSDEV_CHANGE_DIR=~/src/python/


if [ -d ${OSDEV_CHANGE_DIR} ]; then
    mkdir -p ${OSDEV_CHANGE_DIR}
fi


launch_project() {
    if [ ${OSDEV_PROJECT_LAUNCHER:-''} != '' ]; then
        ${OSDEV_PROJECT_LAUNCHER} ${1}
    fi
}

unload_plugin() {
    for v in ${_PLUGIN_VARS[@]}; do
        unset ${v}
    done
    unset PLUGIN_EXIT
    unset PLUGIN_MSG
}

run_plugin() {
    assert_registered_plugin ${1}
    load_plugin "${OSDEV_PLUGINS[${1}]}"
    shift
    run $@
    if [ ${PLUGIN_EXIT:-0} -ne 0 ]; then
        echo "ERROR: ${PLUGIN_MSG}"
    fi
    local _exit=${PLUGIN_EXIT:-0}
    unload_plugin
    exit ${_exit}
}

for_plugins_in() {
    declare -a _plugin_names=("${!1}")
    assert_registered_plugins _plugin_names[@]

    for _plugin_name in ${_plugin_names[@]}; do
        load_plugin ${OSDEV_PLUGINS[${_plugin_name}]}
        ${2}
        unload_plugin
    done
}

echo_plugin_usage_line() {
    declare -a _plugin_names=("${!1}")
    assert_registered_plugins _plugin_names[@]
    local _prefix=${2:-''}

    for _plugin_name in ${_plugin_names[@]}; do
        load_plugin ${OSDEV_PLUGINS[${_plugin_name}]}
        echo "${_prefix}${OSDEV_PLUGIN_USAGE_LINE}"
    done

    unload_plugin
}

assert_registered_plugins() {
    declare -a _plugin_names=("${!1}")
    for _plugin_name in ${_plugin_names[@]}; do
        assert_registered_plugin ${_plugin_name}
    done
}

assert_registered_plugin() {
    if [ ! ${OSDEV_PLUGINS[${1}]+x} ]; then
        echo "Plugin '${1}' not registered"
        exit 1
    fi
}

assert_loaded_plugin() {
    for v in ${_PLUGIN_VARS[@]}; do
        if [ -z ${!v+x} ]; then
            echo "Plugin '${1}' didn't export: ${v}"
            exit 1
        fi
    done
}

load_plugin() {
    unload_plugin
    declare -gxA OSDEV_PLUGIN_ARGS
    . ${1}
    if [ $? -ne 0 ]; then
        echo "Plugin '${1}' doesn't exist"
        exit 1
    fi
}

register_plugin_file() {
    load_plugin ${1}
    assert_loaded_plugin ${1}

    if [ ${OSDEV_PLUGINS[${OSDEV_PLUGIN_NAME}]+x} ]; then
        echo "Plugin '${OSDEV_PLUGIN_NAME}' already registered"
        exit 1
    fi
    OSDEV_PLUGINS[${OSDEV_PLUGIN_NAME}]=${1}
    OSDEV_PLUGIN_NAMES+=(${OSDEV_PLUGIN_NAME})
    unload_plugin
}

register_plugin_dir() {

    for _file in ${1}/*; do
        if [ -f ${_file} ]; then
            register_plugin_file ${_file}
        else
            register_plugin_dir ${_file}
        fi
    done
}

register_plugins() {
    unset OSDEV_PLUGINS
    declare -Ag OSDEV_PLUGINS
    unset OSDEV_PLUGIN_NAMES
    OSDEV_PLUGIN_NAMES=()

    while IFS=':' read -ra _plugin_paths; do
        for d in "${_plugin_paths[@]}"; do
             if [ -z ${d} ]; then
                 continue
             elif [ -f ${d} ]; then
                 register_plugin_file ${d}
             else
                 register_plugin_dir ${d}
             fi
        done
    done <<< ${OSDEV_PLUGIN_PATHS:-''}
}
