#!/usr/bin/env bash

OSDEV_PROJECT_LAUNCHER=${OSDEV_PROJECT_LAUNCHER:-""}
OSDEV_GIT_BASE=${OSDEV_GIT_BASE:-'https://github.com/openstack/'}
OSDEV_SHORT_TERM_DIR=${OSDEV_SHORT_TERM_DIR:-/tmp/}
OSDEV_LONG_TERM_DIR=${OSDEV_LONG_TERM_DIR:-~/src/python/}
OSDEV_GIT_CACHE_DIR=${OSDEV_GIT_CACHE_DIR:-~/.osdev/}
OSDEV_BRANCH=${OSDEV_BRANCH:-master}


declare -Ag OSDEV_PLUGINS
declare -xga ARGS
declare -xgA KWARGS
OSDEV_PLUGIN_NAMES=()
_PLUGIN_VARS=(OSDEV_PLUGIN_VERSION OSDEV_PLUGIN_NAME OSDEV_PLUGIN_DESCRIPTION OSDEV_PLUGIN_ARGS OSDEV_PLUGIN_KW_ARGS)


_exec() {
    ${1}
    local _rc=$?
    if [ ${_rc} -ne 0 ]; then
        echo ${2:-'${1} failed with: ${_rc}'}
        exit ${_rc}
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        local _arg=${1}
        local _kw=''
        if [[ ${_arg} == '-'* ]]; then
            _kw=`echo ${1} | sed 's/-//g'`
            _arg=${2}
            shift
            KWARGS[${_kw}]=${_arg}
        else
            ARGS+=(${_arg})
        fi
        shift
    done

    local _arg_index=0
    for _arg in ${OSDEV_PLUGIN_ARGS[@]}; do
        local _default=''
        if [[ ${_arg} == *':'* ]]; then
            _default=`echo ${_arg} | cut -d ':' -f 2`
            _arg=`echo ${_arg} | cut -d ':' -f 1`
        fi
        local _arg_env_var=OSDEV_`echo $_arg | awk '{print toupper($0)}'`
        if [[ ! ${ARGS[$_arg_index]+e} ]]; then
            if [[ ${!_arg_env_var:-''} != '' ]]; then
                ARGS+=(${!_arg_env_var})
            elif [[ ${_default:-''} != '' ]]; then
                ARGS+=(${_default})
            fi
        fi
        _arg_index=$((_arg_index+1))
    done

    for i in "${!OSDEV_PLUGIN_KW_ARGS[@]}"; do
        local _default=''
        if [[ ${i} == *':'* ]]; then
            _default=`echo ${i} | cut -d ':' -f 2`
            i=`echo ${i} | cut -d ':' -f 1`
        fi
        local _arg_env_var=OSDEV_`echo $i | awk '{print toupper($0)}'`
        if [[ ! ${KWARGS[$i]+e} ]]; then
            if [[ ${!_arg_env_var:-''} != '' ]]; then
                KWARGS[$i]=${!_arg_env_var}
            elif [[ ${_default:-''} != '' ]]; then
                KWARGS[$i]=${_default}
            fi
        fi
    done
}

clone() {
    local _git_url=${1}

    if [[ ${_git_url} != *'://'* ]]; then
        _git_url=${OSDEV_GIT_BASE}${1}
    fi
    if [[ ${_git_url} != *'.git' ]]; then
        _git_url=${_git_url}.git
    fi

    local _src=${OSDEV_GIT_CACHE_DIR}/`echo ${_git_url} | sed 's/https\?:\/\///' | sed 's,/,.,g'`

    if [ ! -d ${_src} ]; then
        _exec "git clone ${_git_url} ${_src}"
    elif test "`find ${_src}/* -mmin +10080`"; then
        # 10080 is 1 week
        echo "This cached repo is a bit old; give me a min to refresh it"
        rm -rf ${_src} || (echo "Can't delete ${_src}";exit 1)
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
        ${OSDEV_PROJECT_LAUNCHER} ${1} &
        echo "Launched via: ${OSDEV_PROJECT_LAUNCHER}"
    fi
}

unload_plugin() {
    for v in ${_PLUGIN_VARS[@]}; do
        unset ${v}
    done
    unset PLUGIN_EXIT
    unset PLUGIN_MSG
}


validate_plugin_args() {
    if [[ ${#ARGS[@]} != ${#OSDEV_PLUGIN_ARGS[@]} ]]; then
        echo "Missing required arguments"
        declare -a _names=(${OSDEV_PLUGIN_NAME})
        echo_plugin_usage_line _names[@] "Usage: "
        exit 1
    fi

    for _kw in "${!KWARGS[@]}"; do
        if [[ ${OSDEV_PLUGIN_KW_ARGS[$_kw]:-''} == '' ]]; then
            echo "Invalid kwarg: ${_kw}"
            exit 1
        fi
    done
}

run_plugin() {
    _cmd=${1}
    shift

    assert_registered_plugin ${_cmd}
    load_plugin "${OSDEV_PLUGINS[${_cmd}]}"

    parse_args $@

    validate_plugin_args

    run

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


echo_current_plugin_usage_line() {
    local _prefix=${1:-''}
    local _cmd_usage="${OSDEV_PLUGIN_NAME}"
    for i in "${!OSDEV_PLUGIN_KW_ARGS[@]}"; do
        if [[ ${i} == *':'* ]]; then
            _default=`echo ${i} | cut -d ':' -f 2`
            i=`echo ${i} | cut -d ':' -f 1`
        fi
        if [[ "${i}" != "0" ]]; then
            _cmd_usage="${_cmd_usage} --${i} <${i}>"
        fi
    done

    for _arg in ${OSDEV_PLUGIN_ARGS[@]}; do
        if [[ ${_arg} == *':'* ]]; then
            _default=`echo ${_arg} | cut -d ':' -f 2`
            _arg=`echo ${_arg} | cut -d ':' -f 1`
        fi
        local _arg_env_var=OSDEV_`echo $_arg | awk '{print toupper($0)}'`
        if [[ ${!_arg_env_var:-''} != '' ]]; then
            _cmd_usage="${_cmd_usage} <${_arg}>"
        else
            _cmd_usage="${_cmd_usage} [${_arg}]"
        fi
    done

    echo "${_prefix}${_cmd_usage}"
}

echo_plugin_usage_line() {
    declare -a _plugin_names=("${!1}")
    assert_registered_plugins _plugin_names[@]
    local _prefix=${2:-''}

    for _plugin_name in ${_plugin_names[@]}; do
        load_plugin ${OSDEV_PLUGINS[${_plugin_name}]}
        echo_current_plugin_usage_line ${_prefix}
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
        if [ ! ${!v+x} ]; then
            if [[ ${v} == OSDEV_PLUGIN_ARGS || ${v} == OSDEV_PLUGIN_KW_ARGS ]]; then
                continue
            fi
            echo "Plugin '${1}' didn't export: ${v}"
            exit 1
        fi
    done
}

load_plugin() {
    unload_plugin
    declare -xga OSDEV_PLUGIN_ARGS
    declare -xgA OSDEV_PLUGIN_KW_ARGS
    . ${1} || (echo "Plugin '${1}' doesn't exist";exit 1)
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
