# Shutdown

General Shutdown Notes

## LLC/DBA

* DBA: abandon assumed name form
  * fill out, sign, then scan submit via SOSUpload.
  * SOSUpload is basically online document submission for forms that don't exist
    on SOSDirect.
  * poorly advertised

## Digital Ocean

1. Login as business account
2. Invite Takeover (personal) account to Team
3. Elevate personal account to "Owner"
4. Personal: change team contact email
5. Personal: remove business payment from team
6. Business: Deactivate account

-- TODO --

4. Replace DO Token (see DO API Tab) with Takeover / personal account's generated DO Token
   * abrepo ops: Packer, Terraform, Ansible - see .env's
5. Shutdown business acount - personal now should be sole owner of team


## Cloudflare

1. Move over all domains to personal
   * export / import DNS records
   * export / import WAF rules (copy expression)
   * verify domain SSL type is the same
2. Replace any API tokens with personal ones
   * Typically terraform whitelist ip ranges of CF servers
3. Remove payment methods
4. Don't close account yet, but just let orphan for now. (Still has receipts,
   once closed email can't be used again)

## AWS

### AWS Organizations

#### Hierarchy

1. nameless "root" creates manager account
   * stashcredentials, never use root again.
2. create IAM administrator user - this is operating account.
3. manager account creates member accounts (these are "sub-root")
4. New Member account
   * stash credentials, never use root again
5. create IAM administrator user - this is operating account.
...

#### Moving AWS Organizations

e.g. From Company to Personal. This preserves all assets, keys, configs, etc.

1. Host AWS Organization invites member root
2. Target Member root: added new default payment card
3. Leave org button -> need to sign up as standalone account (basic)
   * go through verification captcha, sms
4. Now account is standalone, can leave org
5. AWS invite - join host organization
6. Update contact information
