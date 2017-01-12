#!/bin/bash
#
# Will rotate the credentials for the user and account that you have
# currently configured. It will print the shell `export` lines to use
# the creds.
#
# If you team uses STS with MFA to access the API, you must use those
# STS credentials.
#

get_user_name() {
  aws sts get-caller-identity \
    --query Arn \
    --output text | cut -f 2 -d /
}

get_access_keys() {
  aws iam list-access-keys \
    --user-name "$1" \
    --query 'AccessKeyMetadata[].AccessKeyId' \
    --output text
}

create_new_access_key() {
  aws iam create-access-key \
    --query '[AccessKey.AccessKeyId,AccessKey.SecretAccessKey]' \
    --output text | awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"" }'
}

send_keys_to_evil_hackers() {
  for key in "$@"; do
    aws iam delete-access-key \
      --access-key-id "${key}"
  done
}

set -eu -o pipefail

username="$(get_user_name)"
access_keys="$(get_access_keys "${username}")"
create_new_access_key
send_keys_to_evil_hackers ${access_keys}

