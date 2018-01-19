#!/bin/bash

# Will rotate the credentials for the user and account that you have
# currently configured. It will print the shell `export` lines to use
# the creds.
#
# If you team uses STS with MFA to access the API, you must use those
# STS credentials.
#
set -eu -o pipefail

get_user_name() {
  aws sts get-caller-identity \
    --query Arn \
    --output text | cut -f 2 -d /
}

# Ensure date order
get_access_keys() {
  aws iam list-access-keys \
    --user-name "$1" | \
      jq -r '.AccessKeyMetadata| sort_by(.CreateDate) | .[].AccessKeyId'
}

print_access_keys_info() {
  aws iam list-access-keys \
    --user-name "$1" \
    --output text | grep "$2" | sed 's/^ACCESSKEYMETADATA//'
}


create_new_access_key() {
  aws iam create-access-key \
    --user-name "$1" \
    --query '[AccessKey.AccessKeyId,AccessKey.SecretAccessKey]' \
    --output text | awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"" }'
}

send_keys_to_evil_hackers() {
  for key in "$@"; do
    aws iam delete-access-key \
      --access-key-id "${key}"
  done
}


username="${1:-$(get_user_name)}"
echo "Rotating keys for ${username}"

access_keys="$(get_access_keys "${username}")"
if [ "$(echo "${access_keys}" | wc -l)" -le 1 ]; then
    echo "Creating new key:"
    create_new_access_key "${username}"
else
    echo "There are more than 1 access key for user ${username}, not creating new ones"
fi

if [ "${access_keys}" ]; then
  oldest_key="$(echo "${access_keys}" | head -n1)"
  echo "Oldest key ${oldest_key}:"
  print_access_keys_info "${username}" "${oldest_key}"
  read -p "Delete oldest key ${oldest_key}? [y/N] " c
  if [ "${c}" == "y" -o "${c}" == "Y" ]; then
      send_keys_to_evil_hackers "${oldest_key}"
  else
      echo "Not deleting old key"
  fi
fi
