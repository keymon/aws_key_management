#!/bin/bash

set -eu -o pipefail

PASS_CF_DIR=~/gds/paas-cf

echo "ci"
eval $(pass work/gds/aws/gov-paas-ci/credentials.sh)
AWS_ACCOUNT=ci "${PASS_CF_DIR}"/scripts/create_sts_token.sh

echo "staging"
eval $(pass work/gds/aws/gov-paas-staging/credentials.sh)
AWS_ACCOUNT=staging "${PASS_CF_DIR}"/scripts/create_sts_token.sh

echo "prod"
eval $(pass work/gds/aws/gov-paas-prod/credentials.sh)
AWS_ACCOUNT=prod "${PASS_CF_DIR}"/scripts/create_sts_token.sh

echo "dev"
eval $(pass work/gds/aws/gov-paas-dev/credentials.sh)
AWS_ACCOUNT=dev "${PASS_CF_DIR}"/scripts/create_sts_token.sh


