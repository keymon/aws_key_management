Bash script to generate STS tokens
==================================

Set of bash scripts to generate and manage AWS STS tokens.

Use them to assume roles with MFA, into different accounts, etc.

Quick start
-----------

To start using this repo:

 1. Fork this repo.
 2. edit `awssts.sh` to change it to your own config.
 3. add base AWS credentials in pass, with this format:
    ```
export AWS_USER_NAME="user@company.com";
export AWS_ACCOUNT_NAME="user+admin@user";
export AWS_ACCESS_KEY_ID="...";
export AWS_SECRET_ACCESS_KEY="...";
export AWS_SESSION_TOKEN=
```
 4. Source the `awssts.sh` in your `.profile`: `source ~/workspace/aws_key_management/awssts.sh`

Now you can simply switch credentials like this:

```
awssts role:admin@keytwine-root
awssts role:dev@keytwine-sandbox
```

`generate-sts-token.sh`
-----------------------

Creates a new AWS STS token assuming the given role or user.

```
Usage:
./generate-sts-token.sh [-r <role name>] [-a account_id] [-m] [-d duration_in_seconds]

Options:
  -r      Role name to assume.
          If not set, it will generate a STS token for the user.
  -a      Account ID to assume the role in.
          Defaults to the current account id.
  -m      Use MFA code to authenticate.
  -d      Duration in seconds for the token
```

Example: `./generate-sts-token.sh -r admin -m`

`./cached-sts-token.sh `
------------------------

To be used in combination with the previous script, it will kept a
encrypted cached session of the `generate-sts-token.sh`

```
Usage: ./cached-sts-token.sh <id> [generate-sts-token.sh args]
```

You can call it as:

```
AWS_CACHE_GPG_ID=2EA619ED \
	~/workspace/aws_key_management/cached-sts-token.sh \
	admin@keytwine -r admin -m
```

Putting all together: awssts.sh
-------------------------------

With these two scripts, and the [password-store](https://www.passwordstore.org/)
it is easy to create a helper to load the credentials and assume roles:

```
eval $(pass keytwine/aws/hector.rivas+aws.admin_credentials.sh)
AWS_CACHE_GPG_ID=2EA619ED
	~/workspace/aws_key_management/cached-sts-token.sh \
		admin@keytwine -r admin -m
```

Following this approach, there is an example script `awssts.sh` which
can be sourced to provide the function `awssts` which would change the
credentials of the current shell.

Check the Quick Start guide above.
