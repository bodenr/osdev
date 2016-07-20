#!/bin/bash

OSDEV_PLUGIN_VERSION=1.0
OSDEV_PLUGIN_NAME=rebase
declare -xga OSDEV_PLUGIN_ARGS=(dir_or_change)
declare -xgA OSDEV_PLUGIN_KW_ARGS
OSDEV_PLUGIN_KW_ARGS[project]=$'If [dir_or_change] is a change ID, <project> must be set to the change project.'
OSDEV_PLUGIN_KW_ARGS[branch:master]=$'The branch to pull/rebase from. Defaults to \'master\'.'
OSDEV_PLUGIN_KW_ARGS=${OSDEV_PLUGIN_KW_ARGS}


read -r -d '' OSDEV_PLUGIN_DESCRIPTION << EOM
Do an interactive rebase on the said [dir_or_change]. If [dir_or_change] is
an existing directory, an interactive rebase is started atop the current
branch from <branch> (defaults to 'master'). If [dir_or_change] is a change ID
the <project> must be specified and the said [dir_or_change] is fetched from
gerrit before starting an interactive rebase from the latest <branch>.
If defined, the [dir_or_change] will be launched via 'OSDEV_PROJECT_LAUNCHER'
${OSDEV_PROJECT_LAUNCHER} once cloned.
EOM


run() {
    local _repo=${ARGS[1]}
    if [ ! -d ${_repo} ]; then
        if [[ ${KWARGS[project]:-''} == '' ]]; then
            echo "<project> must be set when using change ID."
            exit 1
        fi
        clone ${_repo} ${OSDEV_SHORT_TERM_DIR}/${_repo}
        pushd ${OSDEV_SHORT_TERM_DIR}/${_repo}
        git review -d ${_repo} || (echo "Failed to fetch change: ${_repo}";exit 1)
        local _branch=`git rev-parse --abbrev-ref HEAD`
        local _commit_branch=`echo ${_branch} | cut -d"/" -f3-`
        git branch -m ${_branch} ${_commit_branch} || exit 1
        popd
        _repo=${OSDEV_SHORT_TERM_DIR}/${_repo}
    fi

    pushd ${_repo}
    local _branch=`git rev-parse --abbrev-ref HEAD`
    git checkout ${KWARGS[branch]} && git pull && git checkout ${_branch} && git rebase -i ${KWARGS[branch]}
    PLUGIN_EXIT=$?
    if [ ${PLUGIN_EXIT} -ne 0 ]; then
        PLUGIN_MSG="'git' returned errors."
        return
    fi

    launch_project ${_repo}
    echo "${_rep} interactive rebase started from ${KWARGS[branch]}"
}
