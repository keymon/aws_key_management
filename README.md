Bash script to generate STS tokens
==================================

Set of bash scripts to generate and manage AWS STS tokens.

Use them to assume roles with MFA, into different accounts, etc.

`generate-sts-token.sh`
-----------------------

```
Creates a new AWS STS token assuming the given role or user.

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
