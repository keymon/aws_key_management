#!/bin/bash

echo "Assuming that you did init your creds"
cd $(dirname $0)

for account in ci staging prod dev; do
	export AWS_ACCOUNT="${account}"
	echo "${AWS_ACCOUNT}"

	eval $(pass work/gds/aws/gov-paas-${AWS_ACCOUNT}/credentials.sh)
	. ~/.aws_sts_tokens/ci.sh
	eval $(./rotate_my_access_keys.sh)

	cat <<EOF | pass insert -m work/gds/aws/gov-paas-${AWS_ACCOUNT}/credentials.sh
export -n AWS_SESSION_TOKEN;
export AWS_ACCOUNT="${AWS_ACCOUNT}";
export AWS_ACCOUNT_NAME="gov-paas-${AWS_ACCOUNT}";
export AWS_USER_NAME=hectorrivas;
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}";
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}";
EOF
done



