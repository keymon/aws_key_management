#!/bin/bash

set -eu -o pipefail

SCRIPT_NAME="$0"

duration=3600
use_mfa=

usage() {
  cat <<EOF
Creates a new AWS STS token assuming the given role or user.

Usage:
$SCRIPT_NAME [-r <role name>] [-a account_id] [-m] [-d duration_in_seconds]

Options:
  -r      Role name to assume.
          If not set, it will generate a STS token for the user.
  -a      Account ID to assume the role in.
          Defaults to the current account id.
  -m      Use MFA code to authenticate.
  -d      Duration in seconds for the token
EOF
  exit 1

}

while getopts "a:r:d:m" o; do
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
    m)
      use_mfa=true
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
expire_time="$(($(date '+%s')+3600-10))"

if [ "${use_mfa}" == "true" ]; then
  read -p "MFA Token code for ${user_name}: " token
fi

if [ -z "${role_name:-}" ]; then
  echo "Creating a new session token for ${user_arn}..." 1>&2
  aws sts get-session-token \
    --serial-number "${token_arn}" \
    --duration-seconds "${duration}" \
    --output text \
    --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
    ${token:+--token-code "${token}"} | \
      awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"\n" "export AWS_SESSION_TOKEN=\"" $3 "\"" }'
else
  role_arn="arn:aws:iam::${account_id}:role/${role_name}"
  echo "Creating new session token for role ${role_name}..." 1>&2
  aws sts assume-role \
    --role-arn "${role_arn}" \
    --role-session-name "${user_name%%[+@]*}+${role_name}@${account_id}" \
    --serial-number "${token_arn}" \
    --duration-seconds "${duration}" \
    --output text \
    --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
    ${token:+--token-code "${token}"} | \
      awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"\n" "export AWS_SESSION_TOKEN=\"" $3 "\"" }'
  echo "export AWS_ROLE=${role_name}"
fi
echo "export AWS_SESSION_TOKEN_EXPIRE_DATE=${expire_time}"
