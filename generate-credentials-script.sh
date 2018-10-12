#!/bin/bash

set -e -u -o pipefail

cat <<EOF 2>&1
This script would generate for you a shell script with the AWS creds,
having the AWS_SECRET_ACCESS_KEY encrypted with GPG.

EOF

read -sp "Access Key ID and Secret Access Key? " AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
echo 2>&1
echo 2>&1

GPG_ID="$([ -f ~/.password-store/.gpg-id ] && cat ~/.password-store/.gpg-id)"

encoded_secret_access_key="$(echo "$AWS_SECRET_ACCESS_KEY" | gpg -e ${GPG_ID:+-r $GPG_ID} -a | base64 -w 100000)"


cat << EOF
export AWS_ACCESS_KEY_ID="AKIAI3A7KUQ66Z3MYUPQ"
export AWS_SECRET_ACCESS_KEY="\$(echo '${encoded_secret_access_key}' | base64 --decode | gpg -d --no-verbose --quiet --batch )";
export AWS_SESSION_TOKEN=""
EOF

