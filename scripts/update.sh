#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x

    NPM_ARGS=""
else
    NPM_ARGS="--quiet"
fi

function usage() {
    echo -n \
         "Usage: $(basename "$0")
Updates application by installing Node.js dependencies.
"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ]
    then
        usage
    else
        npm install ${NPM_ARGS}
    fi
fi
