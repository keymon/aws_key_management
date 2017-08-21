_awssts_dir="$(command cd "$(dirname "${BASH_SOURCE}")"; pwd)"
awssts() {
  profile="$1"; shift

  # if an argument is passed, execute it
  if [ "$1" ]; then
    ( awssts "${profile}"; $@ );  return $?
  fi

  local _aws_cache_gpg_id=2EA619ED
  case "$profile" in
    admin@keytwine-root)
      eval $(pass keytwine/aws/hector.rivas+aws.admin_credentials.sh)
      eval $(
        AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
        ${_awssts_dir}/cached-sts-token.sh \
          admin@keytwine-root -r admin -m
      )
      ;;
    dev@keytwine-root)
      eval $(pass keytwine/aws/hector.rivas+aws.dev_credentials.sh)
      eval $(
        AWS_CACHE_GPG_ID="${_aws_cache_gpg_id}" \
        ${_awssts_dir}/cached-sts-token.sh \
          dev@keytwine-root -r dev -m
      )
      ;;
    *)
      echo "awssts <aws_profile>"
      return 1
      ;;
  esac
}

