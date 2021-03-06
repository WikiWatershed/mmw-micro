#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x
fi

function usage() {
    echo -n \
         "Usage: $(basename "$0")
Run project tests.
"
}

SOURCE_ROOT="./src/app/"

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ]
    then
        usage
    else
        # Lint Bash scripts
        if command -v shellcheck > /dev/null; then
            shellcheck scripts/*.sh
        fi

        pushd ${SOURCE_ROOT}
        npm run test
        popd
    fi
fi
