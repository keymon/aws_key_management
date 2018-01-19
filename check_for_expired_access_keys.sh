#!/bin/bash

MAX_DAYS_AGE=60
MAX_AGE=$((24 * 60 * 60 * ${MAX_DAYS_AGE} ))

list_users(){
    aws iam list-users --max-items 10000 | jq -r '.Users[].UserName'
}

list_keys_dates() {
    aws iam list-access-keys --user-name=${user} | \
        jq -r '.AccessKeyMetadata[].CreateDate'
}

for user in $(list_users); do
    for d in $(list_keys_dates); do
        key_epoch="$(date -d "${d}" +%s)"
        now_epoch="$(date +%s)"
        if [ $((${now_epoch} - ${key_epoch} )) -gt ${MAX_AGE} ]; then
            echo "User ${user} has an expired credential: ${d}"
        fi
    done
done
