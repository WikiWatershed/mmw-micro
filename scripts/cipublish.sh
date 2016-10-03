#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x
fi

MMW_MICRO_ENV=${MMW_MICRO_ENV:-staging}

function usage() {
    echo -n \
         "Usage: $(basename "$0")

Publish static website to Amazon S3.
"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ "${1:-}" = "--help" ]; then
        usage
    else
        aws s3 sync --delete --acl authenticated-read ./dist "s3://${MMW_MICRO_ENV}-mmw-micro-origin-us-east-1"
    fi
fi
