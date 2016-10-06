#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x
fi

function usage() {
    echo -n \
         "Usage: $(basename "$0")
Script to execute within the CI environment.
"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ]
    then
        usage
    else
        ./scripts/update.sh --production
        ./scripts/test.sh
    fi
fi
