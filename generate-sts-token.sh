#!/bin/bash

set -eu -o pipefail

SCRIPT_NAME="$0"

duration=3600

usage() {
    cat <<EOF
Creates a set of tokens assuming the given role.

Usage:
    $SCRIPT_NAME [-r <role name>] [-a account_id] [-d duration_in_seconds]

Options:
    -r      Role name to assume
    -a      Account ID to assume the role in. Requires the role.
    -d      Duration in seconds for the token
EOF
    exit 1

}

while getopts "a:r:d:" o; do
    case "${o}" in
        d)
            duration="${OPTARG}"
            ;;
        a)
            account_id="${OPTARG}"
            ;;
        r)
            role_name="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done
shift "$((OPTIND-1))"

user_arn="$(aws sts get-caller-identity --query Arn --output text)"
token_arn="${user_arn/:user/:mfa}"
user_name="${user_arn#*/}"
arn_prefix="${user_arn%:*}"
arn_prefix="${user_arn%:*}"
account_id="${account_id:-$(echo "${user_arn}" | cut -f 5 -d :)}"
expire_time="$(($(date '+%s')+3600))"

read -p "Token code: " token

if [ -z "${role_name:-}" ]; then
    echo "Creating a new session token for ${user_arn}..." 1>&2
    aws sts get-session-token \
        --serial-number "${token_arn}" \
        --duration-seconds "${duration}" \
        --output text \
        --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
        --token-code "${token}" | \
            awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"\n" "export AWS_SESSION_TOKEN=\"" $3 "\"" }'
else
    role_arn="arn:aws:iam::${account_id}:role/${role_name}"
    echo "Creating new session token for role ${role_name}..." 1>&2
    aws sts assume-role \
        --role-arn "${role_arn}" \
        --role-session-name "${user_name}_${account_id}_${role_name}_mfa_command_line" \
        --serial-number "${token_arn}" \
        --duration-seconds "${duration}" \
        --output text \
        --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
        --token-code "${token}" | \
            awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"\n" "export AWS_SESSION_TOKEN=\"" $3 "\"" }'
    echo "export AWS_ROLE=${role_name}"
fi
echo "export AWS_SESSION_TOKEN_EXPIRE_DATE=${expire_time}"
