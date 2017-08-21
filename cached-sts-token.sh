#!/bin/bash
#
# Variables:
#  - AWS_CACHE_GPG_ID to change the GPG key to use
#  - STS_TOKEN_CACHE_DIR to change where the cached tokens are stored
#
set -eu -o pipefail

SCRIPT_NAME="$0"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_NAME}")"; pwd)" # get absolete path

AWS_CACHE_GPG_ID="${AWS_CACHE_GPG_ID:-}"
STS_TOKEN_CACHE_DIR="${STS_TOKEN_CACHE_DIR:-${HOME}/.awssts}"

if [ -z "${1:-}" ]; then
    echo "Usage: $SCRIPT_NAME <id> [generate-sts-token.sh args]"
    exit 1
fi

STS_CACHE_ID_FILE="${STS_TOKEN_CACHE_DIR}/$1.sh.gpg"
shift

decrypt_cached_file() {
    gpg --no-verbose --quiet --batch -d "${STS_CACHE_ID_FILE}" 2>/dev/null
}

cached_exists_and_not_expired() {
    [ -f "${STS_CACHE_ID_FILE}" ] || return 1
    eval $(decrypt_cached_file | grep AWS_SESSION_TOKEN_EXPIRE_DATE)
    [[ "${AWS_SESSION_TOKEN_EXPIRE_DATE:-}" =~ ^-?[0-9]+$ ]] || return 1
    [ "$(date +%s)" -lt "${AWS_SESSION_TOKEN_EXPIRE_DATE}" ] || return 1
    return 0
}

generate_sts_token() {
    mkdir -p "${STS_TOKEN_CACHE_DIR}"
    output="$("${SCRIPT_DIR}/generate-sts-token.sh" $@)"
    echo "${output}" | gpg -a -e --batch ${AWS_CACHE_GPG_ID:+-r ${AWS_CACHE_GPG_ID}} > "${STS_CACHE_ID_FILE}"
}

if ! cached_exists_and_not_expired; then
    generate_sts_token "$@"
fi
decrypt_cached_file
