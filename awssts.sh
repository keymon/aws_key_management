#!/bin/bash
_awssts_dir="$(command cd "$(dirname "${BASH_SOURCE}")"; pwd)"
_awssts_script="${_awssts_dir}/${BASH_SOURCE##*/}"
awssts() {
  aws_account_name="$1"; shift

  # if an argument is passed, execute it
  if [ "$1" ]; then
    ( set -e; awssts "${aws_account_name}"; $@ ); return $?
  fi

  eval $(${_awssts_script} "${aws_account_name}")
}

# Check if the script is being sourced or not
# More info https://stackoverflow.com/a/2687092/395686
if [ "$BASH_SOURCE" != "$0" ]; then
  # The file is being source, stop processing
  return 0
fi

_aws_cache_gpg_id=2EA619ED

aws_account_name="$1"; shift
case "$aws_account_name" in
  user:hector.rivas+admin@keytwine)
    pass keytwine/aws/hector.rivas+aws.admin_credentials.sh
    ;;
  user:hector.rivas+dev@keytwine)
    pass keytwine/aws/hector.rivas+aws.dev_credentials.sh
    ;;
  role:admin@keytwine-root)
    ROOT_AWS_CREDENTIALS_COMMAND="${_awssts_script} user:hector.rivas+admin@keytwine" \
    AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
      ${_awssts_dir}/cached-sts-token.sh \
      ${aws_account_name} -r admin -m
    ;;
  role:dev@keytwine-root)
    ROOT_AWS_CREDENTIALS_COMMAND="${_awssts_script} user:hector.rivas+dev@keytwine" \
    AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
      ${_awssts_dir}/cached-sts-token.sh \
      ${aws_account_name} -r dev -m
    ;;
  role:admin@keytwine-sandbox)
    account_id="$(pass keytwine/aws/sandbox/account_id)"
    ROOT_AWS_CREDENTIALS_COMMAND="${_awssts_script} user:hector.rivas+admin@keytwine" \
    AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
      ${_awssts_dir}/cached-sts-token.sh \
      ${aws_account_name} \
      -a "${account_id}" \
      -r admin -m
    ;;
  role:dev@keytwine-sandbox)
    account_id="$(pass keytwine/aws/sandbox/account_id)"
    ROOT_AWS_CREDENTIALS_COMMAND="${_awssts_script} user:hector.rivas+dev@keytwine" \
    AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
      ${_awssts_dir}/cached-sts-token.sh \
      ${aws_account_name} -a "${account_id}" -r dev -m
    ;;
  *)
    (
      echo "Usage: awssts <aws_account_name>"
      echo
      echo "Available accounts:"
      sed -n "s/^ *\(user:.*\))/  awssts \1/p;s/^ *\(role:.*\))/  awssts \1/p" < "${_awssts_script}" 1>&2
    ) 1>&2
    exit 1
    ;;
esac
