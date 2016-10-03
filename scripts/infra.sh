#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x
fi

MMW_MICRO_ENV=${MMW_MICRO_ENV:-staging}

function usage() {
    echo -n \
         "Usage: $(basename "$0")
Setup infrastructure resources required to support the site.
"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]
then
    if [ "${1:-}" = "--help" ]
    then
        usage
    else
        pushd "$(dirname "$0")/../deployment/terraform"

        # Stop Terraform from trying to apply incorrect state across environments
        if [ -f ".terraform/terraform.tfstate" ] && ! grep -q "${MMW_MICRO_ENV}-mmw-micro-config-us-east-1" ".terraform/terraform.tfstate"; then
            echo "ERROR: Incorrect target environment detected in Terraform state! Please run"
            echo "       the following command before proceeding:"
            echo
            echo "  rm -rf deployment/terraform/.terraform"
            echo
            exit 1
        fi

        terraform remote config \
                  -backend="s3" \
                  -backend-config="region=us-east-1" \
                  -backend-config="bucket=${MMW_MICRO_ENV}-mmw-micro-config-us-east-1" \
                  -backend-config="key=terraform/state" \
                  -backend-config="encrypt=true"

        case "${1}" in
            fmt)
                terraform "$@"
                ;;
            taint)
                terraform "$@"
                ;;
            plan)
                terraform plan \
                          -var-file="${MMW_MICRO_ENV}.tfvars" \
                          -out="${MMW_MICRO_ENV}.tfplan"
                ;;
            apply)
                terraform apply "${MMW_MICRO_ENV}.tfplan"
                terraform remote push
                ;;
            *)
                echo "ERROR: I don't have support for that Terraform subcommand!"
                exit 1
                ;;
        esac

        popd
    fi
fi
