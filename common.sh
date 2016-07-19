#!/usr/bin/env bash

OSDEV_GIT_BASE=${OSDEV_GIT_BASE:-'https://github.com/openstack/'}
OSDEV_SHORT_TERM_DIR=${OSDEV_SHORT_TERM_DIR:-/tmp/}
OSDEV_LONG_TERM_DIR=${OSDEV_LONG_TERM_DIR:-~/src/python/}
OSDEV_GIT_CACHE_DIR=${OSDEV_GIT_CACHE_DIR:-~/.osdev/}


declare -Ag OSDEV_PLUGINS
OSDEV_PLUGIN_NAMES=()
_PLUGIN_VARS=(OSDEV_PLUGIN_VERSION OSDEV_PLUGIN_NAME OSDEV_PLUGIN_USAGE_LINE OSDEV_PLUGIN_DESCRIPTION OSDEV_PLUGIN_ARGS)


_exec() {
    ${1}
    local _rc=$?
    if [ ${_rc} -ne 0 ]; then
        echo ${2:-'${1} failed with: ${_rc}'}
        exit ${_rc}
    fi
}

clone() {
    local _git_url=${1}

    if [[ ${_git_url} != *'://'* ]]; then
        _git_url=${OSDEV_GIT_BASE}${1}
    fi

    local _src=${OSDEV_GIT_CACHE_DIR}/`echo ${_git_url} | sed 's/https\?:\/\///' | sed 's,/,.,g'`

    if [ ! -d ${_src} ]; then
        _exec "git clone ${_git_url} ${_src}"
    fi

    local _dest=${2:-./`basename ${_src} '.git'`}
    cp -r ${_src} ${_dest}
    local _branch=${3:-master}
    pushd ${_dest}
    _exec "git checkout master"
    _exec "git pull"
    _exec "git checkout ${_branch}"
    popd
}

setup() {
    if [ ! -d ${OSDEV_SHORT_TERM_DIR} ]; then
        _exec "mkdir -p ${OSDEV_SHORT_TERM_DIR}"
    fi
    if [ ! -d ${OSDEV_LONG_TERM_DIR} ]; then
        _exec "mkdir -p ${OSDEV_LONG_TERM_DIR}"
    fi
    if [ ! -d ${OSDEV_GIT_CACHE_DIR} ]; then
        echo "Create git dir"
        _exec "mkdir -p ${OSDEV_GIT_CACHE_DIR}"
    fi
}

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
